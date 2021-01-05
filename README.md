# vim-open-in-diffusion

## Requirements

- vim 8?
- An `.arcconfig` file in a parent directory of the current file (usually at the proejct root, next to .git or .hg)
- The `.arcconfig` specifies `phabricator.uri` and `phabricator.callsign` fields.
  Ex: `{ "phabricator.uri": "https://secure.phabricator.com/", "repository.callsign": "P" }`

## Setup

Edit your .vimrc file to Set the default branch name that will be inserted into the url (default is `main`):
```
let g:open_in_diffusion_default_branch = 'main'
```

## Usage

Call the function `GetPhabUrl()` which returns a string or will throw an error if the .arcconfig file is missing/invalid. Or call `GetPhabUrlSafe()` which will catch errors and instead return a error message as a string.
```
:call GetPhabUrl()
:call GetPhabUrlSafe()
```

The resulting url will include a directive to highlight the line your cursor is positioned on. For example, this url will highlight line 3 of .editorconfig: `https://secure.phabricator.com/source/phabricator/browse/master/.editorconfig$3`

If you run the function from Visual Mode, then the ranges of lines you have selected will be highlighted in diffusion instead. If you were recently in visual mode, and have gone back into normal mode without changing the cursor position, then the last-selected range from visual mode will be used.

Both `GetPhabUrl()` and `GetPhabUrlSafe()` accept an optional argument `branch` which will override `g:open_in_diffusion_default_branch`.

## Errors

If the .arcconfig file cannot be found, or if it is missing the required fields an error message will be returned instead of a url.

## Customizing

You can setup your own keybindings to make interacting with the generated url easier.
Here is an example command that prints the url into the command-bar, optionally accepting the branch name argument:
```
command! -nargs=? PhabUrl echo GetPhabUrlSafe(<f-args>)
```

You can call this command like:
```
:PhabUrl 'master'
```
