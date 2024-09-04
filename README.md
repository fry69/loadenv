## loadenv

Load environment variables like API keys or other (sensitive) settings you do not want to be set always into the current bash environment on demand.

## Installation

Put something like this into you `.bashrc` or `.bash_profile` to load the snippet into your bash environment:

```shell
# Loader function (with completion) for *.env files in ~/.env/
source $HOME/.bash/loadenv.sh
```

Create a `.env` directory in your home directory and make it only accessible to you (optional, but a good idea).

```shell
mkdir ~/.loadenv
chmod 700 ~/.loadenv
```

## Usage

Put files ending with `.env` into the `~/.loadenv/` directory containing environment variable definitions.

```shell
# ~/.loadenv/sample.env

SAMPLE_API_KEY=super_secret
```

Make sure the `loadenv.sh` is loaded into your bash environment, then use it like this:

```shell
loadenv sample
```

`loadenv` supports tab completion of all `.env` files found in `~/.loadenv`.

### Additional Commands

- `loadenv list`: Shows all environment variables loaded through loadenv in the current session.
- `loadenv clear`: Unsets all environment variables loaded through loadenv in the current session.

## Tips

Use the `loadenv list` command to see all variables loaded through loadenv:

```shell
loadenv list
```

Use the `loadenv clear` command to unset all variables loaded through loadenv:

```shell
loadenv clear
```

Use the `env` command to list all environment variables currently set (pipe it to `sort` for better readability):

```shell
env | sort
```

## Features

- Tab completion for `.env` files in `~/.loadenv/`
- Keeps track of loaded variables for easy listing and clearing
- Prevents duplicate loading of variables

## Bugs

The current implementation may have problems with spaces in the filenames for `.loadenv` files.

## License

This project is licensed under the [MIT License](LICENSE).
