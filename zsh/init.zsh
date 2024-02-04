# https://github.com/romkatv/zsh4humans/blob/master/.zshrc
# And adapted to my needs
if (( _z4h_initialized )); then
  print -ru2 -- ${(%):-"%F{3}z4h%f: please use %F{2}%Uexec%u zsh%f instead of %F{2}source%f %U~/.zshrc%u"}
  return 1
fi

emulate zsh

emulate zsh -o posix_argzero -c ': ${Z4H_ZSH:=${${0#-}:-zsh}}' # command to start zsh
: ${ZSH_CACHE_DIR:=${XDG_CACHE_HOME:-~/.cache}/zsh-cache}

function z4h() {
  emulate -L zsh

  case $ARGC-$1 in
    1-init)   local -i update=0;;
    1-update) local -i update=1;;
    2-source)
      [[ -r $2 ]] || return
      if [[ ! $2.zwc -nt $2 && -w ${2:h} ]]; then
        zmodload -F zsh/files b:zf_mv b:zf_rm || return
        local tmp=$2.tmp.$$.zwc
        {
          zcompile -R -- $tmp $2 && zf_mv -f -- $tmp $2.zwc || return
        } always {
          (( $? )) && zf_rm -f $tmp
        }
      fi
      source -- $2
      return
    ;;
    *)
      print -ru2 -- ${(%):-"usage: %F{2}z4h%f %Binit%b|%Bupdate%b|%Bsource%b"}
      return 1
    ;;
  esac

  (( _z4h_initialized && ! update )) && exec -- $Z4H_ZSH

  # GitHub projects to clone.
  local github_repos=(
    zsh-users/zsh-syntax-highlighting  # https://github.com/zsh-users/zsh-syntax-highlighting
    zsh-users/zsh-autosuggestions      # https://github.com/zsh-users/zsh-autosuggestions
    romkatv/powerlevel10k              # https://github.com/romkatv/powerlevel10k
    Aloxaf/fzf-tab                     # https://github.com/Aloxaf/fzf-tab
    junegunn/fzf                       # https://github.com/junegunn/fzf
  )
  # Raw scripts to download
  local raw_scripts=(
    'https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion'
    'https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/pj/pj.plugin.zsh'
    'https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/kubectl/kubectl.plugin.zsh'
    'https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/git/git.plugin.zsh'
  )
  # Custom completions
  local -A completions=(
    _terraform 'https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/terraform/_terraform'
    _kubens 'https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/_kubens.zsh'
    _kubectx 'https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/_kubectx.zsh'
  )

  {
    if [[ ! -d $ZSH_CACHE_DIR || ! -d $ZSH_CACHE_DIR/completions  ]]; then
      zmodload -F zsh/files b:zf_mkdir || return
      zf_mkdir -p -- $ZSH_CACHE_DIR || return
      zf_mkdir -p -- $ZSH_CACHE_DIR/completions || return
      update=1
    fi

    # Clone or update all repositories.
    local repo
    for repo in $github_repos; do
      if [[ -d $ZSH_CACHE_DIR/$repo ]]; then
        if (( update )); then
          print -ru2 -- ${(%):-"%F{3}z4h%f: updating %B${repo//\%/%%}%b"}
          >&2 git -C $ZSH_CACHE_DIR/$repo pull --recurse-submodules || return
        fi
      else
        print -ru2 -- ${(%):-"%F{3}z4h%f: installing %B${repo//\%/%%}%b"}
        >&2 git clone --depth=1 --recurse-submodules -- \
          https://github.com/$repo.git $ZSH_CACHE_DIR/$repo || return
      fi
    done

    # Download all raw files
    local raw_script
    for raw_script in $raw_scripts; do
      local out_file=$(basename "$raw_script")
      if [[ ! -f $ZSH_CACHE_DIR/$out_file || $update == 1 ]]; then
          print -ru2 -- ${(%):-"%F{3}z4h%f: downloading raw %B${out_file//\%/%%}%b"}
          curl -L "$raw_script" -o "$ZSH_CACHE_DIR/$out_file"
      fi
    done

    # Download all completion files
    for comp_file comp_url in ${(kv)completions}; do
      if [[ ! -f $ZSH_CACHE_DIR/completions/$comp_file || $update == 1 ]]; then
          print -ru2 -- ${(%):-"%F{3}z4h%f: downloading completion %B${comp_file//\%/%%}%b"}
          curl -L "$comp_url" -o "$ZSH_CACHE_DIR/completions/$comp_file"
      fi
    done

    fpath+="$ZSH_CACHE_DIR/completions"

    if (( _z4h_initialized )); then
      print -ru2 -- ${(%):-"%F{3}z4h%f: restarting zsh"}
      exec -- $Z4H_ZSH
    else
      typeset -gri _z4h_initialized=1
    fi
  } always {
    (( $? )) || return
    local retry
    (( _z4h_initialized )) || retry="; type %F{2}%Uexec%u zsh%f to retry"
    print -ru2 -- ${(%):-"%F{3}z4h%f: %F{1}failed to pull dependencies%f$retry"}
  }
}

z4h init || return

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

bindkey -e # switch to Emacs mode

export HISTFILE=~/.zsh_history                    # the path to the history file.
export HISTSIZE=1000000000                        # infinite command history
export SAVEHIST=1000000000                        # infinite command history

export PROMPT_EOL_MARK='%K{red} %k'               # mark the missing \n at the end of a comand output with a red block
export READNULLCMD=less                           # use `less` instead of the default `more`
export WORDCHARS=''                               # only alphanums make up words in word-based zle widgets
export ZLE_REMOVE_SUFFIX_CHARS=''                 # don't eat space when typing '|' after a tab completion
export zle_highlight=('paste:none')               # disable highlighting of text pasted into the command line

export ZSH_HIGHLIGHT_MAXLENGTH=1024               # don't colorize long command lines (slow)
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets) # main syntax highlighting plus matching brackets
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1            # disable a very slow obscure feature

export MANPAGER="sh -c 'col -bx | bat -l man -p'" # use bat as pager for man
export MANROFFOPT="-c"
