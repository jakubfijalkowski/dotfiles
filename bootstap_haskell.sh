#!/bin/zsh

if [ ! -n "${CABAL_VERSION+1}" ]; then
    readonly CABAL_VERSION=1.22
fi

if [ ! -n "${GHC_VERSION+1}" ]; then
    readonly GHC_VERSION=7.10.1
fi

echo 'Adding ppa:hvr/ghc repo...'
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:hvr/ghc
sudo apt-get update

echo 'Installing ghc and cabal...'
sudo apt-get install cabal-install-$CABAL_VERSION ghc-$GHC_VERSION
source ~/.zshrc

echo 'Installing cabal packages...'
cabal update
cabal install -j alex happy stylish-haskell ghc-mod hoogle haddock aeson \
    hasktags hlint
