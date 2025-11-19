# Watchhist

This script can be used to safe the
watch history of shows watched.<br>
It appends the episode to a text file named `watch-history.txt`
in the `REPO` directory.<br>
The script should pull the latest `WATCHLIST` file from the
specified `REPO` on startup and push the
updated `WATCHLIST` file to the `REPO` on exit.

> [!NOTE]
> Modify the `REPO` and `WATCHLIST` variables to your needs.

Feel free to modify it to your needs.

## Requirements

- `playerctl`
- `ani-cli`
- `grep`
- `tail`

## Usage

Just after starting to watch a show run the script.:

```bash
./watchhist
```
