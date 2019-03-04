alias whatismyip="drill A myip.opendns.com @resolver1.opendns.com | grep IN | tac | head -n 1 | cut -d $'\t' -f5"
alias whatismyipv6="drill -6 AAAA myip.opendns.com @resolver1.opendns.com | grep IN | tac | head -n 1 | cut -d $'\t' -f5"
alias open=xdg-open

if type exa &> /dev/null; then
    alias ls="exa -lh --git"
    alias lsa="exa -lah --git"
    alias lst="exa --tree -L2"
    alias lsT="exa --tree -L"
fi
