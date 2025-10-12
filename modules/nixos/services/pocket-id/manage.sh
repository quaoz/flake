if [[ "$PURGE_CLIENTS" == 1 ]]; then
    PURGE_CLIENTS="true"
fi

panic() {
    echo "$1" >&2
    exit 1
}

req() {
    xh --body --pretty none "$1" "https://id.xenia.dog/api/$2" "x-api-key:@$APIKEY_FILE" "${@:3}" 2>/dev/null || true
}

if [[ -z "$APIKEY_FILE" ]]; then
    panic 'APIKEY_FILE not specified'
elif [[ ! -e "$APIKEY_FILE" ]]; then
    panic "APIKEY_FILE: '$APIKEY_FILE' does not exist"
elif [[ ! -r "$APIKEY_FILE" ]]; then
    panic "APIKEY_FILE: '$APIKEY_FILE' is not readable"
elif [[ -z "$CLIENTS_FILE" ]]; then
    panic 'CLIENTS_FILE not specified'
elif [[ ! -e "$CLIENTS_FILE" ]]; then
    panic "CLIENTS_FILE: '$CLIENTS_FILE' does not exist"
elif [[ ! -r "$CLIENTS_FILE" ]]; then
    panic "CLIENTS_FILE: '$CLIENTS_FILE' is not readable"
fi

readarray -t clients < <(jq -c '.[]' "$CLIENTS_FILE")
known=()

for client in "${clients[@]}"; do
    name="$(jq -r '.name' <<<"$client")"
    id="$(jq -r '.id' <<<"$client")"
    known+=("$id")

    rclient="$(req GET "oidc/clients/$id")"
    if [[ "$(jq 'has("error")' <<<"$rclient")" == true ]]; then
        req POST "oidc/clients" <<<"$client" >/dev/null
        echo "created oidc client: '$name'"
    else
        readarray -t keys < <(jq -cr 'keys[]' <<<"$client")
        needsUpdate=false
        for key in "${keys[@]}"; do
            # compare client fields
            if [[ "$(jq -c ".$key" <<<"$client")" != "$(jq -c ".$key" <<<"$rclient")" ]]; then
                needsUpdate=true
                break
            fi
        done

        if [[ "$needsUpdate" == true ]]; then
            # update client if fields didn't match
            id="$(jq -r '.id' <<<"$rclient")"
            req PUT "oidc/clients/$id" <<<"$client"
            echo "updated oidc client: '$name'"
        fi
    fi
done

if [[ "$PURGE_CLIENTS" == true ]]; then
    knownJson="$(jq -cn '$ARGS.positional' --args "${known[@]}")"
    pageCount=1
    page=1

    while ((page <= pageCount)); do
        rclients="$(req GET 'oidc/clients' "pagination[page]==$page")"
        pageCount="$(jq '.pagination.totalPages' <<<"$rclients")"

        readarray -t unknown < <(jq -c --argjson known "$knownJson" '.data | map(select(.id | IN($known[]) | not)) | map({id, name}) | .[]' <<<"$rclients")
        didDelete=false

        # remove unknown clients
        for client in "${unknown[@]}"; do
            id="$(jq -r '.id' <<<"$client")"
            name="$(jq -r '.name' <<<"$client")"
            req 'DELETE' "oidc/clients/$id"
            echo "removed oidc client: '$name'"
            didDelete=true
        done

        # if we did delete clients refetch the current page
        if [[ "$didDelete" == false ]]; then
            ((page++))
        fi
    done
fi
