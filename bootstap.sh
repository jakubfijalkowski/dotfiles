#!/bin/zsh

echo 'Syncing git submodules...'
git submodule init
git submodule update --recursive
git submodule sync

OLDFILES=('vimrc' 'vim' 'gitconfig' 'ghci')

if hash zsh 2>/dev/null; then
    echo 'ZSH detected, installing oh-my-zsh and .zshrc.'
    OLDFILES+=('zshrc' 'oh-my-zsh' 'zsh-custom')
else
    echo 'ZSH not detected, skipping installation of oh-my-zsh and .zshrc.'
fi

for file in "${OLDFILES[@]}"
do
    if [ -e "$HOME/.$file" ]; then
        echo "Moving ~/.$file to ~/.${file}.old"
        mv "$HOME/.$file" "$HOME/.${file}.old"
    fi
    echo "Linking $(pwd)/$file to ~/.$file"
    ln -s $(pwd)/$file $HOME/.$file
done

# Special-case - terminator configuration
TERMINATOR_CFG='config/terminator/config'
if hash terminator 2>/dev/null; then
    if [ -e "$HOME/.$TERMINATOR_CFG" ]; then
        echo "Moving ~/.$TERMINATOR_CFG to ~/.${TERMINATOR_CFG}.old"
        mv "$HOME/.$TERMINATOR_CFG" "$HOME/.${TERMINATOR_CFG}.old"
    fi
    mkdir -p $HOME/.config/terminator
    ln -s $(pwd)/$TERMINATOR_CFG $HOME/.$TERMINATOR_CFG
fi

