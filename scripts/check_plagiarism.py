#!/usr/bin/env python3
"""Find text in the book copied word for word from a source.

Every run of N consecutive words in a chapter (default 8) is compared with the
text of every PDF and EPUB in ../literature, plus any extra files given with
--also (for example project notes). Neighbouring matches are merged into spans.
Spans wholly inside quotation marks are listed as QUOTE (attributed
quotations); everything else is listed as UNQUOTED and needs a look.

Usage:
    python3 scripts/check_plagiarism.py [-n 8] [--also FILE ...]
    python3 scripts/check_plagiarism.py --self-test

A match is not automatically a problem: numbers, names and your own notes
will match. The output is a list to read, not a verdict.
"""
import argparse
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import booktext  # noqa: E402


def words(t):
    return re.findall(r"[a-z0-9']+", t.lower().replace("’", "'"))


def build_index(sources, n):
    index = {}
    for name, text in sources:
        w = words(text)
        for i in range(len(w) - n + 1):
            index.setdefault(" ".join(w[i:i + n]), name)
    return index


def spans(text, index, n):
    """Yield (length, quoted, source, words) for each matching span."""
    toks = [(m.group(0).lower().replace("’", "'"), m.start())
            for m in re.finditer(r"[A-Za-z0-9’']+", text)]
    quoted = set()
    for m in re.finditer(r"“[^”]*”", text):
        quoted.update(range(m.start(), m.end()))
    hit, src = [False] * len(toks), [None] * len(toks)
    for i in range(len(toks) - n + 1):
        name = index.get(" ".join(t for t, _ in toks[i:i + n]))
        if name:
            for j in range(i, i + n):
                hit[j], src[j] = True, src[j] or name
    i = 0
    while i < len(toks):
        if not hit[i]:
            i += 1
            continue
        j = i
        while j < len(toks) and hit[j]:
            j += 1
        yield (j - i, all(toks[k][1] in quoted for k in range(i, j)), src[i],
               " ".join(t for t, _ in toks[i:j]))
        i = j
    return len(toks)


def run(n, also):
    sources = list(booktext.literature_texts())
    for path in also:
        sources.append((os.path.basename(path), open(path, errors="ignore").read()))
    print(f"Indexing {len(sources)} sources at {n} words...", file=sys.stderr)
    index = build_index(sources, n)

    total, flagged = 0, 0
    for path in booktext.chapter_files():
        text = booktext.chapter_text(path).replace("\n", " ")
        total += len(words(text))
        for length, quoted, src, span in sorted(spans(text, index, n), reverse=True):
            if not quoted:
                flagged += length
            tag = "QUOTE   " if quoted else "UNQUOTED"
            print(f"{tag} {length:3d} words  {os.path.basename(path):28} <- {src[:60]}")
            print(f"         {span[:200]}")
    print(f"\nBook: {total} words. Unquoted words in {n}-word matches: {flagged} "
          f"({100 * flagged / max(total, 1):.2f}%).")


def self_test(n):
    """A sentence copied from a source must be found; a new one must not."""
    source = ("Most benchmarks ignore this: they extract a snippet from an otherwise "
              "long response and score only that, discarding the rest.")
    index = build_index([("planted-source", source)], n)
    copied = "As the paper says, most benchmarks ignore this: they extract a snippet from an otherwise long response."
    original = "Scores taken from one line of a long answer miss most of what matters."
    found = list(spans(copied, index, n))
    clean = list(spans(original, index, n))
    ok = bool(found) and found[0][1] is False and not clean
    print("copied sentence  ->", found)
    print("original sentence ->", clean)
    print("SELF-TEST", "PASSED" if ok else "FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("-n", type=int, default=8, help="words per match (default 8)")
    p.add_argument("--also", nargs="*", default=[], help="extra source files")
    p.add_argument("--self-test", action="store_true")
    a = p.parse_args()
    sys.exit(self_test(a.n) if a.self_test else run(a.n, a.also))
