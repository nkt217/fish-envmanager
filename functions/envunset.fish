function envunset --description "Unset a persistent environment variable"
    if test (count $argv) -eq 0; or contains -- "--help" $argv; or contains -- "-h" $argv
        echo ""
        echo (set_color --bold)"envunset"(set_color normal)" - Unset a persistent environment variable"
        echo ""
        echo (set_color --bold)"Usage:"(set_color normal)
        echo "  envunset NAME [NAME2 ...]    Remove one or more variables"
        echo ""
        echo (set_color --bold)"Examples:"(set_color normal)
        echo "  envunset EDITOR"
        echo "  envunset NODE_ENV DEBUG API_KEY"
        echo ""
        return 0
    end

    set -l config_file ~/.config/fish/conf.d/envmanager.fish
    set -l removed_count 0

    for varname in $argv
        # Validate variable name
        if not string match -qr '^[a-zA-Z_][a-zA-Z0-9_]*$' -- $varname
            echo (set_color red)"Error:"(set_color normal)" '$varname' is not a valid variable name. Skipping."
            continue
        end

        # Check if var is actually set
        if not set -q $varname
            echo (set_color yellow)"Warning:"(set_color normal)" '$varname' is not currently set."
        end

        # Erase from all scopes
        set -e $varname 2>/dev/null
        set -eu $varname 2>/dev/null

        # Remove from config file if it exists
        if test -f $config_file
            set -l tmpfile (mktemp)
            grep -v "^set -Ux $varname " $config_file > $tmpfile 2>/dev/null
            mv $tmpfile $config_file
        end

        echo (set_color green)"Unset"(set_color normal)" $varname"
        set removed_count (math $removed_count + 1)
    end

    if test $removed_count -gt 0
        echo ""
        echo (set_color brblack)"Changes take effect immediately. New shells will not inherit these variables."(set_color normal)
    end
end
