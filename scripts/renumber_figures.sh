#!/bin/sh
# Renumber the figure files after the insertion of Chapter 11, "A Weekly
# Literature Review" (09c-weekly-literature.tex), on 14 October 2026. The
# fifteen figures of the former Chapters 11-16 become ch12-ch17; the \fig{}
# calls in the chapters and the index in book/figures/README.md follow; the
# figures are rebuilt. Run once, from the repository root, by the author:
# agents do not rename files. The list is explicit, so a second run finds
# nothing left to rename and changes nothing.
set -eu
cd "$(dirname "$0")/.."
F=book/figures
pairs="ch11-where-data-goes:ch12-where-data-goes
ch11-architecture:ch12-architecture
ch11-kybele:ch12-kybele
ch12-memory-bandwidth:ch13-memory-bandwidth
ch12-unified-memory:ch13-unified-memory
ch12-size-guide:ch13-size-guide
ch13-procedure:ch14-procedure
ch13-scoring-grid:ch14-scoring-grid
ch14-injection:ch15-injection
ch14-fences:ch15-fences
ch14-shared-layer:ch15-shared-layer
ch15-workflow-checks:ch16-workflow-checks
ch15-resolve:ch16-resolve
ch16-routine:ch17-routine
ch16-small-project:ch17-small-project"
renamed=0
for pair in $pairs; do
  old=${pair%%:*}; new=${pair##*:}
  [ -e "$F/tikz/$old.tex" ] || continue
  n=${old#ch}; n=${n%%-*}; m=${new#ch}; m=${m%%-*}
  git mv "$F/tikz/$old.tex" "$F/tikz/$new.tex"
  [ -e "$F/png/$old.png" ] && git mv "$F/png/$old.png" "$F/png/$new.png"
  [ -e "$F/svg/$old.svg" ] && git mv "$F/svg/$old.svg" "$F/svg/$new.svg"
  [ -e "$F/pdf/$old.pdf" ] && mv "$F/pdf/$old.pdf" "$F/pdf/$new.pdf"
  # the \fig{} call in the chapter and the row in the index
  sed -i '' "s/\\\\fig{$old}/\\\\fig{$new}/" book/chapters/*.tex
  sed -i '' "s/^| $old | $n |/| $new | $m |/" "$F/README.md"
  echo "$old -> $new"
  renamed=$((renamed + 1))
done
echo "$renamed figures renamed"
[ "$renamed" -gt 0 ] || exit 0
# every \fig{} must now name a PNG that exists
missing=0
for name in $(grep -ohE '\\fig\{[^}]+\}' book/chapters/*.tex | sed 's/\\fig{\(.*\)}/\1/' | sort -u); do
  [ -e "$F/png/$name.png" ] || { echo "missing: $F/png/$name.png"; missing=$((missing + 1)); }
done
[ "$missing" -eq 0 ] || exit 1
scripts/build_figures.sh
