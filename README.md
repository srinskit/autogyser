# Autogyser

# Sample configs
```sh
# A variable
home="\/home\/$USER"

# Directory to watch for changes
dir "$HOME/Downloads/test"

# SED supported regex rules to move, i.e. rename files
rule ".*\/([^\/]+).(mp4|mkv)" "$home\/Videos\/\1.\2"
rule ".*\/([^\/]+).(jpg|png)" "$home\/Pictures\/\1.\2"


# Another variable 
root="$home\/Books\/"

# Another directory to watch for changes
dir "$HOME/Books"

# Rules for this directory
rule "($root)(comics\/|)(.*).(cbr|cbz)" "\1comics\/\3.\4"
rule "($root)(docs\/|)(.*).(pdf|doc)" "\1docs\/\3.\4"


# More variables
sleep_for=5
```


# Notes

* Protect your config file. It's content maybe eval-ed.
* POSIX says "dir//file" and "dir/file" are equivalent.
* Remember to escape special characters in your rules. 
* Variables like `$HOME` have unescaped special characters. 