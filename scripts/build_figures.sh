#!/bin/bash
# Build the book's figures from their TikZ sources.
#
#   scripts/build_figures.sh            # every figure
#   scripts/build_figures.sh ch01-loop  # one figure
#
# For each book/figures/tikz/NAME.tex this writes
#   book/figures/pdf/NAME.pdf   vector, what pdflatex drew
#   book/figures/png/NAME.png   300 dpi, included in the book
#   book/figures/svg/NAME.svg   for slides; text converted to outlines
# Needs pdflatex (TeX Live), pdftoppm and pdftocairo (poppler).
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
FIG="$HERE/../book/figures"
BUILD=$(mktemp -d "${TMPDIR:-/tmp}/figures.XXXXXX")
trap 'rm -rf "$BUILD"' EXIT

mkdir -p "$FIG/pdf" "$FIG/png" "$FIG/svg"
cd "$FIG/tikz"

if [ $# -gt 0 ]; then
  files=("$@")
else
  files=(*.tex)
fi

status=0
for f in "${files[@]}"; do
  name=${f%.tex}
  if ! pdflatex -interaction=nonstopmode -halt-on-error \
        -output-directory "$BUILD" "$name.tex" > "$BUILD/$name.out" 2>&1; then
    echo "FAILED  $name"
    grep -A4 '^!' "$BUILD/$name.log" | head -20
    status=1
    continue
  fi
  cp "$BUILD/$name.pdf" "$FIG/pdf/$name.pdf"
  pdftoppm -r 300 -png -singlefile "$FIG/pdf/$name.pdf" "$FIG/png/$name"
  pdftocairo -svg "$FIG/pdf/$name.pdf" "$FIG/svg/$name.svg"
  size=$(pdfinfo "$FIG/pdf/$name.pdf" | awk '/Page size/{printf "%.0f x %.0f pt", $3, $5}')
  echo "ok      $name  ($size)"
done
exit $status
