function envunload --description "Unset environment variables loaded from a .env file"
    if contains -- "--help" $argv; or contains -- "-h" $argv
        echo ""
        echo (set_color --bold)"envunload"(set_color normal)" - Unset variables from a loaded .env file"
        echo ""
        echo (set_color --bold)"Usage:"(set_color normal)
        echo "  envunload              Unload the currently active env file"
        echo "  envunload .env.app1    Unload a specific env file (parses and unsets its keys)"
        echo ""
        return 0
    end

    # If a specific file is given, parse it and unset its keys
    if test (count $argv) -ge 1
        set -l filepath $argv[1]
        set -l resolved ""

        if test -f $filepath
            set resolved $filepath
        else if test -f (pwd)/$filepath
            set resolved (pwd)/$filepath
        else if test -f ~/.config/fish/envs/$filepath
            set resolved ~/.config/fish/envs/$filepath
        end

        if test -z "$resolved"
            echo (set_color red)"Error:"(set_color normal)" Could not find '$filepath'"
            return 1
        end

        set -l unloaded 0
        while read -l line
            set line (string trim -- $line)
            if test -z "$line"; or string match -q "#*" -- $line
                continue
            end
            set line (string replace -r '^export\s+' '' -- $line)
            if not string match -q "*=*" -- $line
                continue
            end
            set -l key (string split -m1 "=" -- $line)[1]
            if not string match -qr '^[a-zA-Z_][a-zA-Z0-9_]*$' -- $key
                continue
            end
            set -eu $key 2>/dev/null
            set -e $key 2>/dev/null
            __envset_remove_from_config $key
            echo (set_color green)"Unset"(set_color normal)" $key"
            set unloaded (math $unloaded + 1)
        end < $resolved

        # Clear tracking state if it matches this file
        if set -q __envmanager_loaded_file; and test "$__envmanager_loaded_file" = "$resolved"
            set -eu __envmanager_loaded_file 2>/dev/null
            set -eu __envmanager_loaded_vars 2>/dev/null
        end

        echo ""
        echo (set_color brblack)"$unloaded variable(s) unset from $resolved"(set_color normal)
        echo ""
        return 0
    end

    # No argument: unload the currently tracked env file
    if not set -q __envmanager_loaded_file
        echo (set_color yellow)"No env file is currently loaded."(set_color normal)
        echo "Use "(set_color cyan)"envload .env.yourfile"(set_color normal)" to load one first."
        return 1
    end

    set -l loaded_file $__envmanager_loaded_file
    set -l loaded_vars

    if set -q __envmanager_loaded_vars
        set loaded_vars $__envmanager_loaded_vars
    end

    echo ""
    echo "About to unset "(count $loaded_vars)" variable(s) from:"
    echo "  $loaded_file"
    echo ""
    echo "Variables: "(string join ", " $loaded_vars)
    echo ""
    read -l -P "Confirm unload? [y/N] " confirm

    if not string match -qi "y" -- $confirm
        echo "Cancelled."
        return 0
    end

    for varname in $loaded_vars
        set -eu $varname 2>/dev/null
        set -e $varname 2>/dev/null
        __envset_remove_from_config $varname
        echo (set_color green)"Unset"(set_color normal)" $varname"
    end

    # Clear tracking state
    set -eu __envmanager_loaded_file 2>/dev/null
    set -eu __envmanager_loaded_vars 2>/dev/null

    echo ""
    echo (set_color brblack)"Unloaded $loaded_file"(set_color normal)
    echo ""
end
