# envmanager for fish shell

A simple plugin to set, unset, and list environment variables that **persist across sessions**.

## Installation

```fish
git clone <this-repo>  # or copy the folder
cd fish-envmanager
fish install.fish
```

Or manually copy the files:

```
functions/envset.fish      -> ~/.config/fish/functions/
functions/envunset.fish    -> ~/.config/fish/functions/
functions/envlist.fish     -> ~/.config/fish/functions/
completions/envmanager.fish -> ~/.config/fish/completions/
```

---

## Commands

### `envset` - Set a variable

```fish
envset NAME VALUE           # persist across sessions (default)
envset NAME=VALUE           # alternate syntax
envset --session NAME VALUE # this session only, not persisted
```

**Examples:**

```fish
envset EDITOR nvim
envset NODE_ENV production
envset API_KEY abc123
envset GOPATH=/home/user/go
envset --session DEBUG 1
```

---

### `envunset` - Remove a variable

```fish
envunset NAME               # remove one variable
envunset NAME1 NAME2 NAME3  # remove multiple at once
```

**Examples:**

```fish
envunset NODE_ENV
envunset API_KEY DEBUG
```

---

### `envlist` - View managed variables

```fish
envlist                 # list variables set via envmanager
envlist NODE            # filter by name pattern
envlist --all           # list ALL exported env variables
```

---

## How it works

- Variables are stored using fish's **universal variables** (`set -Ux`), which persist automatically via `~/.config/fish/fish_variables`.
- Additionally, each variable is written to `~/.config/fish/conf.d/envmanager.fish` so it is explicitly re-exported even if universal variables are cleared or the config is moved.
- The `--session` flag sets a variable only for the current shell, with no persistence.

## File locations

| File | Purpose |
|------|---------|
| `~/.config/fish/conf.d/envmanager.fish` | Persistence record (sourced on every shell start) |
| `~/.config/fish/fish_variables` | Fish universal variable store |
| `~/.config/fish/functions/envset.fish` | `envset` command |
| `~/.config/fish/functions/envunset.fish` | `envunset` command |
| `~/.config/fish/functions/envlist.fish` | `envlist` command |

---

---

### `envload` - Load an env file

```fish
envload .env.app1              # load from cwd or ~/.config/fish/envs/
envload /absolute/path/.env    # load from explicit path
envload --list                 # list available .env files
```

When loading a new file, if a previous env file was already loaded you will be asked whether to unset those variables first.

Sensitive keys (containing `key`, `token`, `secret`, `password`, etc.) are masked in output.

**Supported .env file format:**

```sh
# Comments are ignored
KEY=value
export KEY=value       # export prefix is supported
SECRET="with spaces"   # quoted values supported
```

---

### `envunload` - Unload an env file

```fish
envunload                  # unload the currently active env file (with confirmation)
envunload .env.app1        # parse a specific file and unset its keys
```

---

### File lookup order for `envload` and `envunload`

1. Exact path as given
2. Current working directory
3. `~/.config/fish/envs/`

Store shared env files in `~/.config/fish/envs/` to access them from anywhere.

---

## Uninstalling

```fish
rm ~/.config/fish/functions/envset.fish
rm ~/.config/fish/functions/envunset.fish
rm ~/.config/fish/functions/envlist.fish
rm ~/.config/fish/functions/envload.fish
rm ~/.config/fish/functions/envunload.fish
rm ~/.config/fish/completions/envmanager.fish
rm ~/.config/fish/conf.d/envmanager.fish
```
