# Powerlevel9k
POWERLEVEL9K_MODE="nerdfont-complete"

POWERLEVEL9K_DIR_PATH_ABSOLUTE=false
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_with_folder_marker"
POWERLEVEL9K_SHORTEN_DELIMITER=''
POWERLEVEL9K_SHORTEN_FOLDER_MARKER=".git"

POWERLEVEL9K_PROMPT_ON_NEWLINE=true

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)

zplugin ice compile"{functions/*.zsh,gitstatus/*.zsh}" pick"powerlevel10k.zsh-theme"
zplugin light romkatv/powerlevel10k
