. "$HOME/.local/bin/env"
export PATH="$JAVA_HOME/bin:$PATH"
export NODE_EXTRA_CA_CERTS="/etc/ssl/certs/zscaler_root_ca.pem"
export PATH="/opt/homebrew/opt/python/libexec/bin:$PATH"
export PATH="/opt/homebrew/opt/python/libexec/bin:$PATH"
alias python=/opt/homebrew/bin/python3
alias pip=/opt/homebrew/bin/pip3
# Added by infosec using install_mac.sh to configure the Checkmarx cli tool (secret scanning)
export PATH="$PATH:/Users/harikishen.hosamana/.cx_cli_tool"

eval "$(direnv hook zsh)"
direnv allow ~/.envrc


