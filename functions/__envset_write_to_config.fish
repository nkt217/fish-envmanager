function __envset_write_to_config --argument-names varname varvalue
  set -l config_file ~/.config/fish/conf.d/envmanager.fish

  mkdir -p ~/.config/fish/conf.d

  if not test -f $config_file
    echo "# envmanager - persistent environment variables" > $config_file
    echo "# Managed by envset/envunset. Do not edit manually." >> $config_file
    echo "" >> $config_file
  end

  if test -f $config_file
    set -l tmpfile (mktemp)
    grep -v "^set -Ux $varname " $config_file > $tmpfile 2>/dev/null
    mv $tmpfile $config_file
  end

  echo "set -Ux $varname $varvalue" >> $config_file
end