#!/usr/bin/env zsh

INDEX=$(curl -s https://raw.githubusercontent.com/dotnet/core/master/release-notes/releases-index.json)

update_dotnet_PKGBUILD() {
  local dotnet_version=$1
  local file=$2

  local release_url=$(echo $INDEX | jq -Mr '."releases-index"[] | select(."channel-version" == "'$dotnet_version'") | ."releases.json"')
  local releases=$(curl -s $release_url)
  local version=$(echo $releases | jq -Mr '."latest-release"')
  local release=$(echo $releases | jq -Mr '.releases[] | select(."release-version" == "'$version'")')

  local sdk_url=$(echo $release | jq -Mr '.sdk.files[] | select(.name == "dotnet-sdk-linux-x64.tar.gz") | .url' | sed -e 's/\//\\\//g')

  local runtime_ver=$(echo $release | jq -Mr '.runtime.version')
  local sdk_ver=$(echo $release | jq -Mr '.sdk.version' | sed 's/.\+\..\+\.\(.\+\)/\1/g')
  local final_ver=$(echo "$runtime_ver+$sdk_ver" | tr '-' '+')

  sed -i "s/https.\+dotnet-sdk-.\+.tar.gz/$sdk_url/g" $file
  sed -i "s/pkgver=.\+/pkgver=$final_ver/g" $file
}

update_dotnet_PKGBUILD "2.2" "dotnet2-bin/PKGBUILD"
update_dotnet_PKGBUILD "3.0" "dotnet3-bin/PKGBUILD"
