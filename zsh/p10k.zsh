# Powerlevel9k
typeset -g ZLE_RPROMPT_INDENT=0

typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(root_indicator dir vcs newline prompt_char)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status nordvpn kubecontext azure time newline)

typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION='${P9K_VISUAL_IDENTIFIER}'
typeset -g POWERLEVEL9K_MODE='nerdfont-complete'

typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=

typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR='·'
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_BACKGROUND=
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=238

typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='\uE0B1'
typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='\uE0B3'
typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='\uE0B0'
typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR='\uE0B2'
typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL='\uE0B0'
typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='\uE0B2'
typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=

typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND=76
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND=196
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮' # Not really used
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='Ⅴ'
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_{LEFT,RIGHT}_WHITESPACE=

typeset -g POWERLEVEL9K_DIR_PATH_ABSOLUTE=false
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY='truncate_with_folder_marker'
typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=''
typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER='.git'
typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true

typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
typeset -g POWERLEVEL9K_STATUS_OK=false
typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_STATUS_ERROR=false
typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION=''

typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=0
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=3
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

typeset -g POWERLEVEL9K_NORDVPN_{DISCONNECTED,CONNECTING,DISCONNECTING}_CONTENT_EXPANSION=
typeset -g POWERLEVEL9K_NORDVPN_{DISCONNECTED,CONNECTING,DISCONNECTING}_VISUAL_IDENTIFIER_EXPANSION=

typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_DEFAULT_NAMESPACE=false
typeset -g POWERLEVEL9K_KUBECONTEXT_CLASSES=(
  '*prod*' PROD
  '*test*' TEST
  '*'      DEFAULT)
typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_FOREGROUND=0
typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_BACKGROUND=67
typeset -g POWERLEVEL9K_KUBECONTEXT_TEST_FOREGROUND=0
typeset -g POWERLEVEL9K_KUBECONTEXT_TEST_BACKGROUND=2
typeset -g POWERLEVEL9K_KUBECONTEXT_PROD_FOREGROUND=0
typeset -g POWERLEVEL9K_KUBECONTEXT_PROD_BACKGROUND=124

typeset -g POWERLEVEL9K_AZURE_FOREGROUND=0

typeset -g POWERLEVEL9K_INSTANT_PROMPT=none
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=same-dir

typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|kubens|kubectx'
typeset -g POWERLEVEL9K_AZURE_SHOW_ON_COMMAND='az|terraform'

zplugin ice depth=1
zplugin light romkatv/powerlevel10k
