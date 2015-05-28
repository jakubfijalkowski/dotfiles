readonly HASKELL_BASE='/opt'
readonly CABAL_BASE="$HASKELL_BASE/cabal"
readonly GHC_BASE="$HASKELL_BASE/ghc"
readonly CABAL_LOCAL="$HOME/.cabal/bin"

if [ ! -n "${GHC_STABLE_VERSION+1}" ]; then
    readonly GHC_STABLE_VERSION=7.8.4
fi

if [ ! -n "${CABAL_STABLE_VERSION+1}" ]; then
    readonly CABAL_STABLE_VERSION=1.20
fi

readonly GHC_LATEST_VERSION=$(ls -rv $GHC_BASE | head -n 1)
readonly CABAL_LATEST_VERSION=$(ls -rv $CABAL_BASE | head -n 1)

ghc_path::_get_path_entry() {
    local arg1=$1
    local arg2=$2
    echo "$CABAL_LOCAL:$CABAL_BASE/$arg2/bin:$GHC_BASE/$arg1/bin"
    return 0
}

ghc_path::use_ghc() {
    local VERSION_REGEX='[0-9]{1,2}\.[0-9]{1,2}\.?[0-9]{0,2}'
    local ghc_ver=$1
    local cabal_ver=$2
    local path_org=":$(ghc_path::_get_path_entry $VERSION_REGEX $VERSION_REGEX)"
    if [ ! -d $GHC_BASE/$ghc_ver ]; then
        echo 'GHC version does not exist!'
        return 1
    fi
    if [ ! -d $CABAL_BASE/$cabal_ver ]; then
        echo 'Cabal version does not exist!'
        return 2
    fi
    regexp-replace PATH $path_org ''
    PATH="$PATH:$(ghc_path::_get_path_entry $ghc_ver $cabal_ver)"
    return 0
}

ghc_path::use_stable_ghc() {
    ghc_path::use_ghc $GHC_STABLE_VERSION $CABAL_STABLE_VERSION
}

ghc_path::use_new_ghc() {
    ghc_path::use_ghc $GHC_LATEST_VERSION $CABAL_LATEST_VERSION
}
