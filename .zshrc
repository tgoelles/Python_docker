# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export LANG='en_US.UTF-8'
export LANGUAGE='en_US:en'
export LC_ALL='en_US.UTF-8'
export TERM=xterm

##### Zsh/Oh-my-Zsh Configuration
export ZSH="/root/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(zsh-autosuggestions zsh-completions )

# jupyter lab to use with browser
alias ju="jupyter lab --no-browser --port 8888 --ip=127.0.0.1 --allow-root"
alias mlflow_ui="mlflow ui --backend-store-uri file:///workspaces/avalanche/project/data/09_tracking/mlruns"

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit /tmp/root-code-zsh/.p10k.zsh.
[[ ! -f /tmp/root-code-zsh/.p10k.zsh ]] || source /tmp/root-code-zsh/.p10k.zsh
