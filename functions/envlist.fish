function envlist --description "List environment variables managed by envmanager"
    set -l config_file ~/.config/fish/conf.d/envmanager.fish
    set -l show_all 0
    set -l filter ""

    for arg in $argv
        switch $arg
            case "--all" "-a"
                set show_all 1
            case "--help" "-h"
                echo ""
                echo (set_color --bold)"envlist"(set_color normal)" - List managed environment variables"
                echo ""
                echo (set_color --bold)"Usage:"(set_color normal)
                echo "  envlist              List variables managed by envmanager"
                echo "  envlist --all        List all exported environment variables"
                echo "  envlist PATTERN      Filter by name pattern (e.g. envlist NODE)"
                echo ""
                return 0
            case "*"
                set filter $arg
        end
    end

    if test $show_all -eq 1
        echo ""
        echo (set_color --bold)"All exported environment variables:"(set_color normal)
        echo ""
        if test -n "$filter"
            set -x | string match -i "*$filter*"
        else
            set -x
        end
        return 0
    end

    # Show only envmanager-managed vars
    echo ""
    echo (set_color --bold)"Managed environment variables"(set_color normal)" "(set_color brblack)"(envmanager)"(set_color normal)
    echo (set_color brblack)"Config: $config_file"(set_color normal)
    echo ""

    if not test -f $config_file
        echo (set_color yellow)"No variables set yet."(set_color normal)
        echo "Use "(set_color cyan)"envset NAME VALUE"(set_color normal)" to add one."
        echo ""
        return 0
    end

    set -l count 0

    while read -l line
        # Skip comments and empty lines
        if string match -q "#*" -- $line; or test -z "$line"
            continue
        end

        # Parse: set -Ux VARNAME value
        if string match -q "set -Ux *" -- $line
            set -l parts (string split " " -- $line)
            if test (count $parts) -ge 3
                set -l varname $parts[3]
                set -l varvalue (string join " " $parts[4..-1])

                # Apply filter if provided
                if test -n "$filter"
                    if not string match -qi "*$filter*" -- $varname
                        continue
                    end
                end

                # Get the live value (may differ from config if overridden in session)
                set -l live_value $$varname

                printf "  "(set_color cyan)"%-25s"(set_color normal)"  %s\n" $varname $live_value
                set count (math $count + 1)
            end
        end
    end < $config_file

    if test $count -eq 0
        if test -n "$filter"
            echo (set_color yellow)"No managed variables matching '$filter'."(set_color normal)
        else
            echo (set_color yellow)"No variables set yet."(set_color normal)
            echo "Use "(set_color cyan)"envset NAME VALUE"(set_color normal)" to add one."
        end
    else
        echo ""
        echo (set_color brblack)"$count variable(s) managed. Use 'envunset NAME' to remove."(set_color normal)
    end
    echo ""
end
