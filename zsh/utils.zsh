alias whatismyip="curl -4 ifconfig.co/ip"
alias whatismyipv6="curl -6 ifconfig.co/ip"
alias open=xdg-open

if type exa &> /dev/null; then
    alias ls="exa -lh --git"
    alias lsa="exa -lah --git"
    alias lst="exa --tree -L2"
    alias lsT="exa --tree -L"
fi
