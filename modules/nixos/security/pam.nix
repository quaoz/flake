{
  security = {
    # use ssh keys to authenticate when on a remote connection
    pam = {
      sshAgentAuth.enable = true;

      services = {
        sudo.sshAgentAuth = true;
        sudo-rs.sshAgentAuth = true;
      };
    };
  };
}
