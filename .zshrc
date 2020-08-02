# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/joshuabroomberg/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir rbenv virtualenv pyenv)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs)
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=’red’

export TERM="xterm-256color"

# Add a space in the first prompt
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%f"
# Visual customisation of the second prompt line
local user_symbol="$"
if [[ $(print -P "%#") =~ "#" ]]; then
    user_symbol = "#"
fi
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%{%B%F{black}%K{yellow}%} $user_symbol%{%b%f%k%F{yellow}%} %{%f%}"

# Syntax highlighting
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  zsh-autosuggestions
  virtualenv
)

source $ZSH/oh-my-zsh.sh

# Unique tab history
unsetopt inc_append_history
unsetopt share_history

# Status bar
source $HOME/.iterm2_shell_integration.zsh
iterm2_print_user_vars() {
  iterm2_set_user_var xx yy
}

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nano'
else
   export EDITOR='nano'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# VS CODE
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

# Python aliases
# https://opensource.com/article/19/5/python-3-default-mac

# (the wrong way)
# alias pip=/usr/local/bin/pip3
# alias python=/usr/local/bin/python3

# Right way (personal)
# (right way - pyenv)
#if command -v pyenv 1>/dev/null 2>&1; then
#  eval "$(pyenv init -)"
#fi

# virtualenv wrapper
# https://opensource.com/article/19/6/python-virtual-environments-mac
# export WORKON_HOME=~/.virtualenvs
# mkdir -p $WORKON_HOME
# source ~/.pyenv/versions/3.8.5/bin/virtualenvwrapper.sh

# Domino config

# pyenv

# jenv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Domino dev command
alias domino-frontend="./build/clean_frontend_assets.sh && dev/start-frontend-dev.sh"
alias domino-backend="./sbt-minikube"
alias domino-cd="cd ~/work/Domino/domino"
alias domino-up="/Applications/iTerm.app/Contents/Resources/it2run /Users/joshuabroomberg/Library/ApplicationSupport/iTerm2/Scripts/domino.py"
# alias domino-up="tmux new -s mysession teamocil domino"

# Platform repo
export PATH="$PATH:/Users/joshuabroomberg/Documents/Domino.nosync/platform-apps/bin"
eval "$(pyenv init -)"
test -e /Users/joshuabroomberg/.iterm2_shell_integration.zsh && source /Users/joshuabroomberg/.iterm2_shell_integration.zsh || true

# Git
git() {
    if [[ $@ == "st" ]]; then
        command git status
    elif [[ $1 == "ac" ]]; then
        command git add .; git commit -m "$2"
    elif [[ $1 == "c" ]]; then
        command git commit -m "$2"
    elif [[ $1 == "ammend" ]]; then
        command git commit --amend --no-edit 
    else
        command git "$@"
    fi
}
