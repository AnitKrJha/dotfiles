# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the GPG_TTY to be the same as the TTY, either via the env var
# or via the tty command.
#if [ -n "$TTY" ]; then
#  export GPG_TTY=$(tty)
#else
#  export GPG_TTY="$TTY"
#fi

PATH="$HOME/.go/bin:$PATH"
if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export EDITOR=nvim

# SSH_AUTH_SOCK set to GPG to enable using gpgagent as the ssh agent.
#export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
#gpgconf --launch gpg-agent

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

zle_highlight+=(paste:none)

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'
alias ll='exa --icons --long'
# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
# Created by newuser for 5.
# 9
# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

run() {
    local file="$1"
    local extension="${file##*.}"

    # Temporary files for output and errors
    local output_file="output.log"
    local error_file="error.log"

    case "$extension" in
        c)
            gcc "$file" -o "${file%.*}" 2> "$error_file"
            if [ $? -eq 0 ]; then
                ./"${file%.*}" > "$output_file" 2>> "$error_file"
            fi
            ;;
        cpp)
            g++ "$file" -o "${file%.*}" 2> "$error_file"
            if [ $? -eq 0 ]; then
                ./"${file%.*}" > "$output_file" 2>> "$error_file"
            fi
            ;;
        py)
            python "$file" > "$output_file" 2> "$error_file"
            ;;
        js)
            node "$file" > "$output_file" 2> "$error_file"
            ;;
        *)
            echo -e "${RED}Unsupported file type: $extension${NC}"
            return 1
            ;;
    esac

    # Output section
    echo -e "${YELLOW}------------------- Output -------------------${NC}"
    if [ -s "$output_file" ]; then
        cat "$output_file"
    else
        echo -e "${RED}No output${NC}"
    fi

    # Errors section
    echo -e "${YELLOW}\n------------------- Errors -------------------${NC}"
    if [ -s "$error_file" ]; then
        cat "$error_file"
    else
        echo -e "${GREEN}No errors${NC}"
    fi

    # Clean up
    rm -f "$output_file" "$error_file"
    
    if [[ "$extension" == "c" || "$extension" == "cpp" ]]; then
        rm -f "${file%.*}"
    fi
}

