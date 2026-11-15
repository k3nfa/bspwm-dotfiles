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

# SSH con colores en máquinas remotas
alias ssh='TERM=xterm-256color ssh'

extractPorts () {
	if [ -z "$1" ]; then
		echo -e "\n[!] Uso: extractPorts <archivo-nmap-greppable>\n"
		return 1
	fi

	ports="$(cat "$1" | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
	ip_address="$(cat "$1" | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"

	echo -e "\n[*] Extracting information...\n" > extractPorts.tmp
	echo -e "\t[*] IP Address: $ip_address" >> extractPorts.tmp
	echo -e "\t[*] Open ports: $ports\n" >> extractPorts.tmp

	echo -n $ports | xsel -b
	echo -e "[*] Ports copied to clipboard\n" >> extractPorts.tmp

	batcat -l java extractPorts.tmp
	rm extractPorts.tmp
}



# Recordar la ultima carpeta usada y abrir nuevas terminales ahi
autoload -Uz add-zsh-hook

_save_cwd() {
	pwd > "$HOME/.last_dir"
}
add-zsh-hook chpwd _save_cwd

if [ -f "$HOME/.last_dir" ]; then
	cd "$(cat "$HOME/.last_dir")" 2>/dev/null
fi
