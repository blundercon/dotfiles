if status is-interactive
    # Commands to run in interactive sessions can go here
end

# For Linux
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# For MacOS
eval "$(/opt/homebrew/bin/brew shellenv)"


set --export --append PATH "/opt/homebrew/opt/node@22/bin"
set -gx PATH /opt/homebrew/opt/python/libexec/bin $PATH
alias mkvenv "python -m venv venv"

# Zscaler Root CA
set -x PATH "/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home/bin:$PATH"


direnv hook fish | source
direnv allow ~/.envrc

