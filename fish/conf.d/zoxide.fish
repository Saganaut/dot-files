# Initialize zoxide (smarter cd) if installed
if status is-interactive
    if command -q zoxide
        zoxide init fish | source
    end
end
