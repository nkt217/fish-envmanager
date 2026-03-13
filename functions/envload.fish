function envload --description "Load environment variables from a .env file"
    # Help
    if test (count $argv) -eq 0; or contains -- "--help" $argv; or contains -- "-h" $argv
        echo ""
        echo (set_color --bold)"envload"(set_color normal)" - Load environment variables from a .env file"
        echo ""
        echo (set_color --bold)"Usage:"(set_color normal)
        echo "  envload .env.app1             Load from current dir or ~/.config/fish/envs/"
        echo "  envload /absolute/path/.env   Load from explicit path"
        echo "  envload --list                List available env files"
        echo ""
        echo (set_color --bold)"Examples:"(set_color normal)
        echo "  envload .env.app1"
        echo "  envload .env.production"
        echo "  envload ~/projects/myapp/.env"
        echo ""
        return 0
    end

    # List available env files
    if contains -- "--list" $argv; or contains -- "-l" $argv
        __envload_list
        return 0
    end

    set -l filepath $argv[1]

    # Resolve file path: exact path first, then cwd, then ~/.config/fish/envs/
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
        echo "Looked in:"
        echo "  - $filepath (absolute)"
        echo "  - "(pwd)/$filepath
        echo "  - ~/.config/fish/envs/$filepath"
        return 1
    end

    # Parse the env file to get variable names
    set -l new_vars
    set -l new_names
    set -l skipped 0

    while read -l line
        # Skip blank lines and comments
        set line (string trim -- $line)
        if test -z "$line"; or string match -q "#*" -- $line
            continue
        end

        # Support: KEY=VALUE, export KEY=VALUE
        set line (string replace -r '^export\s+' '' -- $line)

        if not string match -q "*=*" -- $line
            echo (set_color yellow)"Warning:"(set_color normal)" Skipping invalid line: $line"
            set skipped (math $skipped + 1)
            continue
        end

        set -l key (string split -m1 "=" -- $line)[1]
        set -l val (string split -m1 "=" -- $line)[2]

        # Strip surrounding quotes from value
        set val (string trim -c '"' -- $val)
        set val (string trim -c "'" -- $val)

        # Validate key name
        if not string match -qr '^[a-zA-Z_][a-zA-Z0-9_]*$' -- $key
            echo (set_color yellow)"Warning:"(set_color normal)" Skipping invalid key: $key"
            set skipped (math $skipped + 1)
            continue
        end

        set -a new_names $key
        set -a new_vars "$key=$val"
    end < $resolved

    if test (count $new_names) -eq 0
        echo (set_color yellow)"No valid variables found in $resolved"(set_color normal)
        return 1
    end

    # Check if there is a currently loaded env file
    set -l prev_file ""
    set -l prev_names

    if set -q __envmanager_loaded_file
        set prev_file $__envmanager_loaded_file
        if set -q __envmanager_loaded_vars
            set prev_names $__envmanager_loaded_vars
        end
    end

    # Ask about previously loaded vars if applicable
    set -l unload_prev 0
    if test -n "$prev_file"; and test (count $prev_names) -gt 0
        echo ""
        echo (set_color yellow)"Previously loaded:"(set_color normal)" $prev_file"
        echo "Variables: "(string join ", " $prev_names)
        echo ""
        read -l -P "Unset previously loaded variables before loading new file? [y/N] " confirm
        if string match -qi "y" -- $confirm
            set unload_prev 1
        end
    end

    # Unload previous vars if requested
    if test $unload_prev -eq 1
        for varname in $prev_names
            set -eu $varname 2>/dev/null
            set -e $varname 2>/dev/null
            __envset_remove_from_config $varname
        end
        echo (set_color brblack)"Unset "(count $prev_names)" previous variable(s)."(set_color normal)
    end

    # Load new variables
    set -l loaded_names
    for entry in $new_vars
        set -l key (string split -m1 "=" -- $entry)[1]
        set -l val (string split -m1 "=" -- $entry)[2]
        set -Ux $key $val
        __envset_write_to_config $key $val
        set -a loaded_names $key
    end

    # Track which file and vars are currently loaded
    set -Ux __envmanager_loaded_file $resolved
    set -Ux __envmanager_loaded_vars $loaded_names

    # Summary
    echo ""
    echo (set_color green)"Loaded $resolved"(set_color normal)
    echo ""
    for entry in $new_vars
        set -l key (string split -m1 "=" -- $entry)[1]
        set -l val (string split -m1 "=" -- $entry)[2]
        # Mask values that look like secrets
        if string match -qri "(key|token|secret|password|pass|pwd|auth|credential)" -- $key
            printf "  "(set_color cyan)"%-25s"(set_color normal)"  "(set_color brblack)"*** (masked)"(set_color normal)"\n" $key
        else
            printf "  "(set_color cyan)"%-25s"(set_color normal)"  %s\n" $key $val
        end
    end
    if test $skipped -gt 0
        echo ""
        echo (set_color yellow)"$skipped line(s) skipped due to invalid format."(set_color normal)
    end
    echo ""
end


function __envload_list
    set -l dirs (pwd) ~/.config/fish/envs

    echo ""
    echo (set_color --bold)"Available .env files:"(set_color normal)
    echo ""

    set -l found 0
    for dir in $dirs
        if not test -d $dir
            continue
        end
        set -l files (find $dir -maxdepth 1 -name ".env*" -type f 2>/dev/null)
        if test (count $files) -gt 0
            echo (set_color brblack)"$dir"(set_color normal)
            for f in $files
                set -l fname (basename $f)
                if set -q __envmanager_loaded_file; and test "$__envmanager_loaded_file" = "$f"
                    echo "  "(set_color green)"* $fname"(set_color normal)" (currently loaded)"
                else
                    echo "    $fname"
                end
                set found (math $found + 1)
            end
            echo ""
        end
    end

    if test $found -eq 0
        echo (set_color yellow)"No .env files found in "(pwd)" or ~/.config/fish/envs/"(set_color normal)
        echo ""
    end
end
