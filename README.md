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
mkdir ~/.env
chmod 700 ~/.env
```

## Usage

Put files ending with `.env` into this directory containing environment variable definitions.

```shell
# ~/.env/sample.env

SAMPLE_API_KEY=super_secret
```

Make sure the `loadenv.sh` is loaded into your bash environment, the use it like this:

```shell
loadenv sample
```

The snippet supports tab expansion of all `.env` files found the `~/.env` directory.

Use the built-in `unset` command to remove a environment variable from the current bash environment:

```shell
unset sample
```

Use the built-in `env` command to list all environment variable currently set (pipe it to `sort`, otherwise it is jumbled mess):

```shell
env | sort
```

## Bugs

The current implementation may have problems with spaces in the filename for `.env` files.

## License

This project is licensed under the [MIT License](LICENSE).
