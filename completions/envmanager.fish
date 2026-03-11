# Completions for envset
complete -c envset -s h -l help    --description "Show help"
complete -c envset -s g -l global  --description "Set for all sessions (universal)"
complete -c envset -s s -l session --description "Set for this session only"

# Completions for envunset - suggest currently set variables
complete -c envunset -s h -l help  --description "Show help"
complete -c envunset -f -a "(set -x | string replace -r ' .*' '')" --description "Exported variable"

# Completions for envlist
complete -c envlist -s h -l help --description "Show help"
complete -c envlist -s a -l all  --description "List all exported variables"

# Completions for envload
complete -c envload -s h -l help --description "Show help"
complete -c envload -s l -l list --description "List available .env files"
# Suggest .env files from cwd and ~/.config/fish/envs/
complete -c envload -f -a "(find (pwd) ~/.config/fish/envs/ -maxdepth 1 -name '.env*' -type f 2>/dev/null | xargs -I{} basename {})" \
    --description ".env file"

# Completions for envunload
complete -c envunload -s h -l help --description "Show help"
complete -c envunload -f -a "(find (pwd) ~/.config/fish/envs/ -maxdepth 1 -name '.env*' -type f 2>/dev/null | xargs -I{} basename {})" \
    --description ".env file"
