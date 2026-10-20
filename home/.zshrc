# Powerlevel10k
source /usr/share/powerlevel10k/powerlevel10k.zsh-theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Historial
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt histignorealldups sharehistory autocd

# Autocompletado
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# Plugins
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Teclas Inicio / Fin / Supr
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

# Atajos útiles
export PATH="$HOME/.local/bin:$PATH"

# lsd: iconos y colores
alias ls='lsd --group-dirs=first'
alias ll='lsd -lah --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias lt='lsd --tree'

# Efecto Matrix
alias matrix='cmatrix -a -b -C cyan'

# bat en lugar de cat (números de línea y colores)
if command -v bat >/dev/null; then BATCMD=bat; elif command -v batcat >/dev/null; then BATCMD=batcat; fi
[ -n "${BATCMD:-}" ] && alias cat="$BATCMD --paging=never"

# Esc + Esc: añade o quita "sudo" al comando
sudo-command-line() {
  [[ -z $BUFFER ]] && zle up-history
  if [[ $BUFFER == sudo\ * ]]; then BUFFER="${BUFFER#sudo }"; else BUFFER="sudo $BUFFER"; fi
  zle end-of-line
}
zle -N sudo-command-line
bindkey -M emacs '\e\e' sudo-command-line

# fzf: Ctrl+R historial, Ctrl+T archivos, Alt+C directorios
command -v fzf >/dev/null && source <(fzf --zsh)
