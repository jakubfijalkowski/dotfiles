
get_path_entry() {
    local arg1=$1
    local arg2=$2
    echo "$HOME/.cabal/bin:/opt/cabal/$arg2/bin:/opt/ghc/$arg1/bin"
}

use_ghc() {
    local VERSION_REGEX='[0-9]{1,2}\.[0-9]{1,2}\.?[0-9]{0,2}'
    local ghc_ver=$1
    local cabal_ver=$2
    local path_org=":$(get_path_entry $VERSION_REGEX $VERSION_REGEX)"
    if ! [[ $ghc_ver =~ $VERSION_REGEX ]]
    then
        echo 'Invalid GHC version!'
        return 1
    fi
    if ! [[ $cabal_ver =~ $VERSION_REGEX ]]
    then
        echo 'Invalid Cabal version!'
        return 2
    fi
    regexp-replace PATH $path_org ''
    PATH="$PATH:$(get_path_entry $ghc_ver $cabal_ver)"
}

use_stable_ghc() { use_ghc 7.8.4 1.20 }
use_new_ghc() { use_ghc 7.10.2 1.22 }

