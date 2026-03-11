#!/usr/bin/env fish
# install.fish - Install envmanager into your fish config

set -l fish_config ~/.config/fish
set -l functions_dir $fish_config/functions
set -l completions_dir $fish_config/completions
set -l script_dir (dirname (status --current-filename))

echo ""
echo "Installing envmanager..."
echo ""

# Create directories if needed
mkdir -p $functions_dir $completions_dir

# Copy function files
for f in $script_dir/functions/*.fish
    cp $f $functions_dir/
    echo "  Installed function: "(basename $f)
end

# Copy completions
for f in $script_dir/completions/*.fish
    cp $f $completions_dir/
    echo "  Installed completions: "(basename $f)
end

echo ""
echo (set_color green)"envmanager installed successfully!"(set_color normal)
echo ""
echo "Available commands:"
echo "  "(set_color cyan)"envset"(set_color normal)"    NAME VALUE      Set a persistent env variable"
echo "  "(set_color cyan)"envunset"(set_color normal)"  NAME            Remove a persistent env variable"
echo "  "(set_color cyan)"envlist"(set_color normal)"                   List managed variables"
echo "  "(set_color cyan)"envload"(set_color normal)"   .env.app1       Load all vars from an env file"
echo "  "(set_color cyan)"envunload"(set_color normal)"                 Unload the currently loaded env file"
echo ""
echo "Reload your shell or run "(set_color yellow)"source ~/.config/fish/config.fish"(set_color normal)" to activate."
echo ""
