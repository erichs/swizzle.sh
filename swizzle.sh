#!/usr/bin/env sh
# swizzle.sh by erichs
# sweet text manipulation utilities for your shell!

# version: 1.0.2

# install: source this script in your ~/.profile or ~/.${SHELL}rc script
# known to work on bash, zsh, and ksh93

clip () {
  about 'appropriate commandline copy|paste'
  example 'cat file | clip # copies'
  example 'clip | grep foo # pastes'
  example 'echo zzfoobarzz | clip | grep foo # inline tee copy'
  group 'swizzle'

  if [ -t 0 ]; then
    # stdin is a terminal, so paste clipboard to stdout
    _clippaste
  else
    if [ -t 1 ]; then
      # stdout is a terminal, so copy clipboard from stdin
      _clipcopy
    else
      # stdin & stdout are pipes, so copy AND paste
      _clipcopy && _clippaste
    fi
  fi
}

color () {
  # if you need more highlighting functionality, check out the excellent colout tool:
  # http://nojhan.github.io/colout/
  about 'hilight output matching PATTERN with COLOR'
  param "1: PATTERN | 'none' "
  param "1: if 'none', remove all coloring"
  param '2: COLOR # one of: black, blue, cyan, green, magenta, red, yellow, or white'
  param '2: default if not given is: red'
  example "$ cat file | color '^/home.*' blue"
  example "$ cat file | color 'ruby' "
  example "$ ls -l --color | color none"
  group 'swizzle'

  if [ "$1" = 'none' ]; then
    sed 's/\x1b\[[0-9;]*m//g'
  else
    typeset pattern="$1|$"
    typeset color="${2:-red}"
    case $color in
      (black) color='1;30';;
      (blue) color='1;34';;
      (cyan) color='1;36';;
      (green) color='1;32';;
      (magenta) color='1;35';;
      (red) color='1;31';;
      (yellow) color='1;33';;
      (white) color='1;37';;
      (*) echo "color '$color' not supported" > /dev/stderr; return 1 ;;
    esac
    GREP_COLOR="${color}" grep -E --color=always "$pattern"
  fi
}

firstcol () {
  about 'prints first column of text'
  group 'swizzle'

  cut -d' ' -f 1
}

lastcol () {
  about 'prints last column of text'
  group 'swizzle'

  awk '{print $NF}'
}

lc () {
  about 'transforms UPPERCASE text to lowercase'
  example '$ echo "WHEREFORE art thou?" | lc'
  group 'swizzle'

  tr '[:upper:]' '[:lower:]'
}

stripfirst () {
  about 'remove first column of space-delimited text'
  group 'swizzle'

  awk '{for (f=2; f<=NF; ++f) { if (f!=2) {printf("%s",OFS);} printf("%s",$f)} printf("\n")}'
}

uc () {
  about 'transforms lowercase text to UPPERCASE'
  example '$ echo "WHEREFORE art thou?" | uc'
  group 'swizzle'

  tr '[:lower:]' '[:upper:]'
}

# housekeeping and clipboard detection
for f in about author example group param version
do
    eval "$f() { :; }"
done
unset f

typeset clipcopy_cmd=
if $(command -v pbcopy >/dev/null); then
  clipcopy_cmd='pbcopy'
elif $(command -v xsel >/dev/null); then
  clipcopy_cmd='xsel -bi'
fi

typeset clippaste_cmd=
if $(command -v pbpaste >/dev/null); then
  clippaste_cmd='pbpaste'
elif $(command -v xsel >/dev/null); then
  clippaste_cmd='xsel -bo'
fi

if [ -z "$clipcopy_cmd" ] || [ -z "$clippaste_cmd" ]; then
  echo "swizzle.sh: No clipboard support available, install pbcopy (osx) or xsel (linux)!"
  unset -f clip
else
  eval "_clipcopy ()  { $clipcopy_cmd; }"
  eval "_clippaste () { $clippaste_cmd; }"
fi
