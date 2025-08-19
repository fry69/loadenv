# loadenv

Load environment variables such as API keys or other sensitive settings into your current bash environment on demand, without having them permanently set in your shell.

### Features

- Tab completion for `.env` files in `~/.loadenv/`
- Tracks loaded variables for easy listing and clearing
- Prevents duplicate loading of variables

### Installation

Add the following to your `.bashrc` or `.bash_profile` to load the loadenv functionality:

```shell
# Loader function (with completion) for *.env files in ~/.loadenv/
source $HOME/.bash/loadenv.sh
```

Create a `.loadenv` directory in your home directory and restrict access to your user only (recommended for security):

```shell
mkdir ~/.loadenv
chmod 700 ~/.loadenv
```

### Usage

Place files ending with `.env` in the `~/.loadenv/` directory containing environment variable definitions.

```shell
# ~/.loadenv/sample.env

SAMPLE_API_TOKEN=super_secret
```

Once `loadenv.sh` is loaded into your bash environment, use it as follows:

```shell
$ loadenv sample
Loaded 1 vars: SAMPLE_API_TOKEN
```

Use `loadenv list` to see all variables currently loaded through loadenv:

```shell
$ loadenv list
Loaded environment variables:
SAMPLE_API_TOKEN
```

Use `loadenv clear` to unset all variables loaded through loadenv:

```shell
$ loadenv clear
All loadenv variables have been unset for this session.
```

### Tab Completion

`loadenv` supports tab completion for all `.env` files found in `~/.loadenv/`, as well as internal commands.

### Tips

Use the `env` command to list all currently set environment variables (pipe to `sort` for better readability):

```shell
env | sort
```

### Known Issues

- The current implementation may have problems with spaces in `.env` filenames
- The test script should run in a safe environment, preferably a container

### License

This project is licensed under the [MIT License](LICENSE).
