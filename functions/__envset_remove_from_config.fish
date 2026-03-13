function __envset_remove_from_config --argument-names varname
  set -l config_file ~/.config/fish/conf.d/envmanager.fish
  if test -f $config_file
    set -l tmpfile (mktemp)
    grep -v "^set -Ux $varname " $config_file > $tmpfile 2>/dev/null
    mv $tmpfile $config_file
  end
end