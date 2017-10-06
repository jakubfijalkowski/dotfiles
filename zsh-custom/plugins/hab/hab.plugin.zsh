if hash hab 2>/dev/null; then
    hab cli completers --shell zsh > "${0:h}/_hab"
    chmod +x "${0:h}/_hab"
    fpath+="${0:h}"
fi
