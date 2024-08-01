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

Put files ending with `.env` into this directory containing environment variable definitions.

```shell
# ~/.env/sample.env

SAMPLE_API_KEY=super_secret
```

Make sure the `loadenv.sh` is loaded into your bash environment, then use it like this:

```shell
loadenv sample
```

`loadenv` supports tab expansion of all `.env` files found in `~/.loadenv`.

## Tips

Use the built-in `unset` command to remove environment variables from the current bash environment:

```shell
unset sample
```

Use the `env` command to list all environment variable currently set (pipe it to `sort`, otherwise it is a jumbled mess):

```shell
env | sort
```

## Bugs

The current implementation may have problems with spaces in the filename for `.loadenv` files.

## License

This project is licensed under the [MIT License](LICENSE).
