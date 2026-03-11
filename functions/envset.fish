function envset --description "Set a persistent environment variable"
    # Parse flags
    set -l scope "user"
    set -l args

    for arg in $argv
        switch $arg
            case "--global" "-g"
                set scope "universal"
            case "--session" "-s"
                set scope "session"
            case "--help" "-h"
                __envset_help
                return 0
            case "*"
                set -a args $arg
        end
    end

    # Validate argument count
    if test (count $args) -lt 1
        echo (set_color red)"Error:"(set_color normal)" No variable name provided."
        echo "Usage: envset [--global] NAME VALUE"
        echo "       envset [--global] NAME=VALUE"
        return 1
    end

    # Support both NAME VALUE and NAME=VALUE syntax
    set -l varname
    set -l varvalue

    if string match -q "*=*" -- $args[1]
        set varname (string split -m1 "=" -- $args[1])[1]
        set varvalue (string split -m1 "=" -- $args[1])[2]
    else if test (count $args) -ge 2
        set varname $args[1]
        set varvalue $args[2..-1]
    else
        echo (set_color red)"Error:"(set_color normal)" No value provided for '$args[1]'."
        echo "Usage: envset NAME VALUE   or   envset NAME=VALUE"
        return 1
    end

    # Validate variable name
    if not string match -qr '^[a-zA-Z_][a-zA-Z0-9_]*$' -- $varname
        echo (set_color red)"Error:"(set_color normal)" '$varname' is not a valid environment variable name."
        return 1
    end

    # Set the variable based on scope
    switch $scope
        case "universal"
            # Universal vars persist across ALL sessions and are exported automatically
            set -Ux $varname $varvalue
            echo (set_color green)"Set"(set_color normal)" $varname "(set_color yellow)"(global, all sessions)"(set_color normal)
        case "session"
            # Local to this session only, not persisted
            set -x $varname $varvalue
            echo (set_color green)"Set"(set_color normal)" $varname "(set_color yellow)"(this session only)"(set_color normal)
        case "user"
            # Persisted via config.fish (survives new sessions for this user)
            set -Ux $varname $varvalue
            __envset_write_to_config $varname $varvalue
            echo (set_color green)"Set"(set_color normal)" $varname "(set_color yellow)"(persisted to config)"(set_color normal)
    end
end


function __envset_write_to_config --argument-names varname varvalue
    set -l config_file ~/.config/fish/conf.d/envmanager.fish

    # Create conf.d dir and file if needed
    mkdir -p ~/.config/fish/conf.d

    if not test -f $config_file
        echo "# envmanager - persistent environment variables" > $config_file
        echo "# Managed by envset/envunset. Do not edit manually." >> $config_file
        echo "" >> $config_file
    end

    # Remove existing entry for this var if present
    if test -f $config_file
        set -l tmpfile (mktemp)
        grep -v "^set -Ux $varname " $config_file > $tmpfile 2>/dev/null
        mv $tmpfile $config_file
    end

    # Append the new entry
    echo "set -Ux $varname $varvalue" >> $config_file
end


function __envset_help
    echo ""
    echo (set_color --bold)"envset"(set_color normal)" - Set a persistent environment variable"
    echo ""
    echo (set_color --bold)"Usage:"(set_color normal)
    echo "  envset NAME VALUE          Persist var across sessions (default)"
    echo "  envset NAME=VALUE          Alternate syntax"
    echo "  envset --global NAME VALUE Same as default (universal scope)"
    echo "  envset --session NAME VALUE  Set for this session only (not persisted)"
    echo ""
    echo (set_color --bold)"Options:"(set_color normal)
    echo "  -g, --global    Set as universal variable (all sessions)"
    echo "  -s, --session   Set for current session only"
    echo "  -h, --help      Show this help"
    echo ""
    echo (set_color --bold)"Examples:"(set_color normal)
    echo "  envset EDITOR nvim"
    echo "  envset NODE_ENV=production"
    echo "  envset --session DEBUG 1"
    echo ""
end
