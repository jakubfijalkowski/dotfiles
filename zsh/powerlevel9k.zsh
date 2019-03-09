# Powerlevel9k
P9K_MODE="nerdfont-complete"

P9K_DIR_SHORTEN_STRATEGY="truncate_with_folder_marker"
P9K_DIR_SHORTEN_DELIMITER=''
P9K_DIR_SHORTEN_FOLDER_MARKER=".git"
P9K_DIR_PATH_ABSOLUTE=false

P9K_PROMPT_ON_NEWLINE=true

P9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
P9K_RIGHT_PROMPT_ELEMENTS=(status time)

zplugin ice ver"next" \
    compile"{functions/**/*.p9k,segments/**/*.p9k,functions/**/*.zsh,segments/**/*.zsh,functions/autoload/*}"
zplugin light bhilburn/powerlevel9k
