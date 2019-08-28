#!/usr/bin/zsh

pushd xcwd-tsarn
makepkg -Ccsi
popd

pushd dotnet2-bin
makepkg -Ccsi
popd

pushd dotnet3-bin
makepkg -Ccsi
popd
