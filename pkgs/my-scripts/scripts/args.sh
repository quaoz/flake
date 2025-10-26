#!/usr/bin/env bash

# args? flags? opts?
#
# arguments (args, pargs, ...):
#   - *positional* arguments
#   - e.g. '<file>'
#
# flags:
#   - just boolean options
#   - e.g. '--quiet'
#
# options (opts, ...):
#   - options which take an argument
#   - e.g. '--input <FILE_NAME>'

flags=()
opts=()
args=()

declare -A meta
vargs=()

# max lengths used for '--help' formatting
max_flags=0
max_opts=0
max_args=0

# flag --> variable name, e.g. v2f["-q"] --> 'QUIET'
declare -A f2v
# variable name --> flags string, e.g. v2f["QUIET"] --> '-q, --quiet'
declare -A v2f
# variable name --> value
declare -A vals
# variable name --> description
declare -A descs

# shellcheck disable=SC1091
source ansi

wrapped_ansi() {
	if [[ $NO_ANSI == true ]]; then
		echo -n "$1"
	else
		ansi "$@"
	fi
}

usage() {
	local str
	str="$(wrapped_ansi "Usage:" "bold" "underline") $(wrapped_ansi "$NAME" "bold")"

	if ((${#opts[@]} > 0 || ${#flags[@]} > 0)); then
		str+=" [OPTIONS]"
	fi

	local arg
	for arg in "${args[@]}"; do
		str+=" <$arg>"
	done

	if [[ $VARIADIC == true ]]; then
		str+=' -- ...'
	fi
	str+='\n'

	if [[ $NO_HELP != true && $1 != true ]]; then
		str+="\nFor more information, try '$(wrapped_ansi "--help" "bold")'.\n"
	fi

	echo "$str"
}

panic() {
	printf '%s %s\n\n%b' "$(wrapped_ansi 'error:' 'yellow')" "$1" "$(usage)" >&2
	exit 1
}

help() {
	local pffmt
	local pfargs=()

	if [[ -n $DESCRIPTION ]]; then
		pffmt="$DESCRIPTION\n\n"
	fi

	pffmt+="$(usage "true")"

	if ((${#flags[@]} > 0)); then
		pffmt+="\n$(wrapped_ansi 'Flags:' 'bold' 'underline')\n"
		local var
		for var in "${flags[@]}"; do
			pffmt+="    %-${max_flags}s    %s\n"
			pfargs+=("${v2f[$var]}" "${descs[$var]}")
		done

		if [[ $NO_HELP != true ]]; then
			pffmt+="    %-${max_flags}s    %s\n"
			if [[ $NO_SHORT_HELP == true ]]; then
				pfargs+=('--help')
			else
				pfargs+=('-h, --help')
			fi
			pfargs+=('show this message')
		fi

	fi

	if ((${#opts[@]} > 0)); then
		pffmt+="\n$(wrapped_ansi 'Options:' 'bold' 'underline')\n"
		local var
		for var in "${opts[@]}"; do
			pffmt+="    %-${max_opts}s    %s\n"
			pfargs+=("${v2f[$var]} <$var>" "${descs[$var]}")
		done
	fi

	if ((${#args[@]} > 0)); then
		pffmt+="\n$(wrapped_ansi 'Arguments:' 'bold' 'underline')\n"
		local var
		for var in "${args[@]}"; do
			pffmt+="    %-${max_args}s    %s\n"
			pfargs+=("<$var>" "${descs[$var]}")
		done
	fi

	# shellcheck disable=SC2059
	printf "$pffmt" "${pfargs[@]}" >&2
	exit
}

add_flags() {
	local var="$1"
	local flagstr="${*:2}"

	if [[ -z $flagstr ]]; then
		panic "no flags specified for $var"
	fi

	v2f[$var]="${flagstr// /, }"
	local flag
	for flag in "${@:2}"; do
		if [[ -n ${f2v[$flag]} ]]; then
			panic "multiple arguments use the '$flag' flag"
		elif [[ $flag =~ ^-- ]]; then
			if [[ $flag == -- ]]; then
				panic "invalid flag '$flag'"
			fi
		elif [[ $flag =~ ^- ]]; then
			if ((${#flag} != 2)); then
				panic "short flags (-) should only be one character"
			fi
		else
			panic "invalid flag '$flag'"
		fi

		f2v["$flag"]="$var"
	done
}

parse_line() {
	local line_num="$1"

	eval "set -- $2"
	# the arg type: (arg|flag|opt)
	local type="$1"
	# the target variable name
	local var="$2"
	# the arg description
	local desc="$3"
	# skip past common options
	shift 3

	if [[ -z $type ]]; then
		panic "no type specified in line $line_num"
	elif [[ -z $var ]]; then
		panic "no variable name specified in line $line_num"
	elif [[ -z $desc ]]; then
		panic "no description specified in line $line_num"
	fi

	# check the variable name is unique
	if [[ -n ${descs[$var]} ]]; then
		panic "multiple arguments use '$var' as the variable name"
	fi

	# add the description
	descs["$var"]=$desc

	case "${type,,}" in
	arg)
		args+=("$var")

		if [[ -n $1 ]]; then
			panic "unknown token '$1' in line $line_num"
		fi

		# update longest arg
		local str="<${var}>"
		if ((${#str} > max_args)); then
			max_args=${#str}
		fi
		;;
	flag)
		flags+=("$var")
		meta["$var"]="flag"
		add_flags "$var" "$@"

		# update longest flag
		local str="${v2f[$var]}"
		if ((${#str} > max_flags)); then
			max_flags=${#str}
		fi
		;;
	opt)
		opts+=("$var")
		add_flags "$var" "$@"

		# update longest opt
		local str="${v2f[$var]} <$var>"
		if ((${#str} > max_opts)); then
			max_opts=${#str}
		fi
		;;
	*)
		panic "unknown type '$type' in line $line_num"
		;;
	esac
}

parse() {
	# reset everything
	unset meta f2v v2f descs
	declare -gA meta
	declare -gA f2v
	declare -gA v2f
	declare -gA descs
	flags=()
	opts=()
	args=()
	max_args=0
	max_opts=0

	if [[ $NO_HELP == true ]]; then
		max_flags=0
	elif [[ $NO_SHORT_HELP == true ]]; then
		# '--help'
		max_flags=6
	else
		# '-h, --help'
		max_flags=10
	fi

	local line
	local line_num=0
	while IFS= read -r line; do
		((line_num++))

		# skip empty lines
		if [[ -z ${line// /} ]]; then
			continue
		fi

		parse_line "$line_num" "$line"
	done <<<"$1"
}

process() {
	# reset values
	unset vals
	declare -gA vals

	local pos=0
	while (($# > 0)); do
		if [[ $1 == '--' && $VARIADIC == true ]]; then
			# vargs
			vargs=("${@:2}")
			return
		elif [[ $NO_HELP != true && ($1 == "--help" || ($1 == "-h" && $NO_SHORT_HELP != true)) ]]; then
			# help
			help
		elif [[ $1 =~ ^- && ! $1 =~ ^-- ]] && ((${#1} > 2)); then
			# block of short flags
			local block="$1"
			for ((i = 1; i < ${#block}; i++)); do
				var="${f2v["-${block:i:1}"]}"

				if [[ ${meta["$var"]} == "flag" ]]; then
					vals["$var"]=true
				elif ((i + 1 == ${#block})); then
					# only last one can be an option
					vals["$var"]="$2"
					shift
				else
					panic "unexpected option '$(wrapped_ansi "-${block:i:1}" "yellow")' found"
				fi
			done
		elif [[ $1 =~ ^- ]]; then
			# options
			var="${f2v["$1"]}"
			if [[ -z $var ]]; then
				panic "unexpected option '$(wrapped_ansi "$1" "yellow")' found"
			fi

			if [[ ${meta["$var"]} == "flag" ]]; then
				vals["$var"]=true
			else
				vals["$var"]="$2"
				shift
			fi
		else
			# pargs
			if ((pos >= ${#args[@]})); then
				panic "unexpected argument '$(wrapped_ansi "$1" "yellow")' found"
			else
				var="${args[pos++]}"
				vals["$var"]="$1"
			fi
		fi

		shift
	done
}

# set options for parsing our own args
NAME="${0##*/}"
DESCRIPTION='script to simplify bash argument parsing'
NO_HELP=false
NO_SHORT_HELP=false
VARIADIC=true
NO_ANSI=false
EXPORT_PANIC=false

ARGS='
arg NAME "the program name"
arg ARGS "the argument specification"
opt DESCRIPTION "the program description" -d --description
flag NO_ANSI "do not use ansi escape codes for formatting" --no-ansi
flag NO_HELP "disable the -h and --help flags" --no-help
flag NO_SHORT_HELP "disable the -h flag" --no-short-help
flag VARIADIC "return arguments after \"--\" as \"VARGS\"" -v --variadic
flag EXPORT_PANIC "export panic function" -p --export-panic
'

# parse our own args
parse "$ARGS"
process "$@"

# cleanup our own arguments
unset ARGS NAME DESCRIPTION NO_ANSI NO_HELP NO_SHORT_HELP EXPORT_PANIC

# set our args
for var in "${!vals[@]}"; do
	declare "$var"="${vals[$var]}"
done

# skip over our args
set -- "${vargs[@]}"

parse "$ARGS"
process "$@"

unset panic
if [[ $EXPORT_PANIC == true ]]; then
	__ARGS_ERROR_STR="$(wrapped_ansi 'error:' 'yellow')"
	__ARGS_USAGE_STR="$(usage)"

	panic() {
		printf '%s %s\n\n%b' "$__ARGS_ERROR_STR" "$1" "$__ARGS_USAGE_STR" >&2
		exit 1
	}

	export __ARGS_ERROR_STR __ARGS_USAGE_STR
	export -f panic
fi

# TODO: refactor so we don't have to do this
unset max_args max_flags max_opts                                        # max lengths
unset args flags opts f2v v2f descs meta                                 # core
unset -f add_flags ansi wrapped_ansi help parse parse_line process usage # functions

# export vars
for var in "${!vals[@]}"; do
	export "$var"="${vals[$var]}"
done

if [[ $VARIADIC == true ]]; then
	export VARGS="${vargs[*]}"
fi

# leftovers
unset var vals VARIADIC vargs
