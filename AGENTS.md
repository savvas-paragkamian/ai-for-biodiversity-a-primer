# AGENTS.md

Conventions for agents working in this repository. Written in response to things
that have actually gone wrong. Read before editing.

## What this is

A LaTeX textbook, `book/`, called *AI for Ecologists: A Primer*. Source material
is the Markdown notes in this directory and the papers in `../literature/`.

`NOTES.md` is the outline the book follows. Treat it as the table of contents:
if you add a chapter, it should correspond to something there, and if you find
yourself wanting a section that isn't in `NOTES.md`, say so rather than
inventing one.

## Never

- **Never delete files.** Not in `../literature/`, not anywhere. If something
  looks redundant, say so and leave it.
- **Never cite a paper that isn't in `../literature/`.** No citations from model
  memory. This is the single rule that matters most here — the book argues
  against exactly that failure, so the book must not commit it.
- **Never invent a DOI, arXiv ID, page number or volume.** Take them from the
  PDF, or from the `.bib`/`.ris` file next to it, or leave the field out.
- **Never commit.** The author commits.
- **Never add a LaTeX package** without saying why it's needed.

## Bibliography

`book/references.bib` is the only bibliography. Grouped into themed sections
with comment headers; keys are `authorYEARkeyword`.

Before any reference goes in:

1. The source document exists in `../literature/`.
2. Its DOI resolves through Crossref, or its arXiv ID resolves through the arXiv
   API, and the returned title matches the entry.
3. Anything with neither identifier is verified by hand and the entry says what
   kind of document it is.

Verification is scripted, not sampled. Run it over the whole file after any
change to the bibliography — it takes about ten minutes and there is no
acceptable reason to skip it. All 42 DOIs and all 23 arXiv IDs currently pass.

Every entry must be cited at least once. `biber` reports no undefined keys and
the file should have no orphans either.

## Prose

The book is for working ecologists, not for machine learning researchers.

- **Plain words over jargon.** Not "binding constraint", "load-bearing",
  "compositional", "posture", "leverage", "second-order effects", "substrate",
  "defensible". Say what you mean. If a term is genuinely technical and the book
  needs it, define it on first use and add it to the glossary.
- **British spelling**, Oxford-style `-ise`.
- **Don't hedge and don't inflate.** No "it's worth noting", no "cutting-edge",
  no "revolutionary".
- **Attribute claims.** A factual assertion either cites a source in the
  bibliography or is clearly framed as the author's judgement.
- **Dissent stays in.** `mishra2026notready` argues ecology isn't ready for AI.
  That argument is represented fairly throughout and is not to be smoothed away.

## Formatting

Minimal. That is the deliberate house style; don't improve it.

- `book` class, Latin Modern, no colour except the grey code background.
- `\begin{keypoint}` for a section's one real takeaway. **At most one per
  chapter.** There were 24 in the first draft; that was a tic, not a structure.
  If you add one, remove one.
- Tables only where a table beats a paragraph. Currently 10. Don't add a table
  that restates the prose next to it.
- `\code{}` for literals, `\term{}` for a term being introduced.
- Cross-references with `cleveref`: `\Cref{ch:powers}`, `\Cref{tab:hardware}`.
- Citations: `\textcite{}` in running prose, `\parencite{}` parenthetically.
- Labels: chapters `ch:*`, tables `tab:*`, appendices `app:*`.
- No Greek or other non-Latin characters in the `.tex` files — the build is
  `pdflatex` with T1 fonts and they fail. Transliterate.

## Build

No Makefile, deliberately. One command:

```bash
cd book && latexmk -pdf main.tex
```

Or by hand: `pdflatex` → `biber` → `pdflatex` → `pdflatex`.
Clean with `latexmk -C`.

The build must finish with **zero** errors. Check `main.log`:

```bash
grep -c '^!' book/main.log        # must be 0
grep -i warn book/main.blg        # must be empty
```

Warnings about overfull boxes under ~2pt are acceptable. Undefined citations
and undefined references are not.

## Secrets

`agentic-coding.md` contained a live Anthropic API key in plain text. It should
be revoked and removed. Do not copy credentials from the notes into the book,
into examples, or into any file. Example keys in the text must be obviously fake.

## Style of work

- Small, reviewable changes. One chapter at a time.
- Show the diff. Don't rewrite a file wholesale to make one edit.
- If a scripted edit asserts a match and the assertion fails, stop and report —
  don't loosen the pattern until something matches.
- Report what actually happened, including what didn't work. A verification
  script that finds nothing because it's broken is worse than no script; check
  that a check can fail before trusting it that it passed.
