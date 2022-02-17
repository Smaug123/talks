#!/bin/sh

USER_DIR=$(readlink -f "$1")
WORKDIR=$(mktemp -d -p "$USER_DIR")

cd "$WORKDIR" || exit 1

SHELL="/bin/sh"

# Build PDFs from LaTeX. Do the build twice to sort out any bookmarks.
# For some reason, using $0 instead of `sh` makes Hadolint warn about the single-quotes not expanding expressions
# shellcheck disable=SC2016
find "$USER_DIR" -type f -name '*.tex' -exec "$SHELL" -c '
  output=$(dirname "$@")/$(basename "$@" .tex).pdf
  echo "$@ - $output"
  HOME=$(pwd) SOURCE_DATE_EPOCH=1622905527 pdflatex "$@" || exit 1
  HOME=$(pwd) SOURCE_DATE_EPOCH=1622905527 pdflatex "$@" || exit 1
  mv "$(basename "$output")" "$output" || exit 1
' -- {} \; || exit 1

cd "$USER_DIR" || exit 1
rm -r "$WORKDIR"

