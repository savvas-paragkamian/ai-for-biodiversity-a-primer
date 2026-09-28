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
4. The sentence citing it says what the source says. Open the PDF and check.
   A citation that resolves but does not support its sentence is still wrong.

Verification is scripted, not sampled. Run `python3 scripts/verify_bib.py`
over the whole file after any change to the bibliography — it takes a few
minutes and there is no acceptable reason to skip it. There are 116 entries:
all 48 DOIs and all 28 arXiv IDs currently pass, and 40 entries have neither and
were checked by hand. Grant DOIs (CORDIS, `10.3030/...`) carry their title in
Crossref's `project` field; the script handles that. Each script in `scripts/`
has a `--self-test` that plants errors; run it after changing a script.

- **A citation file is not a source.** `CambridgeCore_Citation_28Sep2026.txt`
  (Seth 2026) has no PDF beside it, so it is not cited.
- **Web articles:** take the URL from the PDF's page header only if it is
  complete. A truncated URL (`...`) means no `url` field. If the document is
  undated, say in `note` how the year was inferred.

Every entry must be cited at least once. `biber` reports no undefined keys and
the file should have no orphans either.

**Known problem, unresolved:** `openai2026huggingface` is cited in
`05-ai-ready-data.tex` and `12-security-and-biorisk.tex` for model files carrying
executable payloads. The OpenAI page is about agents escaping an evaluation
sandbox, not about model files. Those two sentences need another source or
rewording; the author decides which.

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
  The same holds elsewhere: Mitchell and Bengio read the 2026 agent incidents
  differently (Chapter 12), and Wickham's view that local models are not
  worth it for beginners sits in the local-first chapter on purpose.
- **When sources disagree on a fact,** state only what they agree on, or give
  both with attribution. Don't pick the more dramatic version.
- **Paraphrase.** Run `scripts/check_plagiarism.py`; an UNQUOTED match against a
  source in `../literature/` gets reworded or put in quotation marks.
- **Sentences under 35 words.** `scripts/check_language.py` flags longer ones,
  along with American spellings and the banned words above.

## Formatting

Minimal. That is the deliberate house style; don't improve it.

- `book` class, Latin Modern, no colour except the grey code background.
- `\begin{keypoint}` for a section's one real takeaway. **At most one per
  chapter.** There were 24 in the first draft; that was a tic, not a structure.
  There are now 12. If you add one, remove one.
- Tables only where a table beats a paragraph. Currently 6. Don't add a table
  that restates the prose next to it.
- `\code{}` for literals, `\term{}` for a term being introduced.
- Cross-references with `cleveref`: `\Cref{ch:powers}`, `\Cref{tab:hardware}`.
- Citations: `\textcite{}` in running prose, `\parencite{}` parenthetically.
- Labels: chapters `ch:*`, tables `tab:*`, appendices `app:*`
  (`app:glossary`, `app:checklists`, `app:tutorials`).
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

After changing prose, also run:

```bash
python3 scripts/check_language.py      # style, spelling, long sentences
python3 scripts/check_plagiarism.py    # 8-word matches against ../literature
```

## Web material: Appendix C

Videos, newsletters, blogs, awesome lists and tool repositories are not
bibliography entries. They go in `book/chapters/A3-tutorials.tex`
(`app:tutorials`), in these sections: videos grouped by publisher (conference
sessions, company channels, independent channels, researchers), then
Newsletters, Blogs, Awesome lists, and Tool repositories (Agents / Running
models locally / Research and text).

- **Names come from the source, not the notes.** The notes' labels were wrong for
  three of twelve videos. Titles come from YouTube's oEmbed endpoint, newsletter
  and blog names from the site's own `<title>`, repositories from
  `api.github.com/repos/OWNER/NAME`.
- **Repositories:** list moved repos at their current address. Leave out
  archived ones, and remove them from the chapters too (Roo Code was archived in
  May 2026 and has been removed from Chapter 1).
- Strip tracking parameters from URLs. If a URL overflows the line, link to a
  shorter parent and name the rest in the text.
- Anna's Blog was left out deliberately (a shadow library); only the author adds
  it.

## People worth following

The list in `14-keeping-up.tex` includes every person with three or more
entries in `references.bib`, plus the author's own picks. Each entry cites that
person's work. Take affiliations from the PDFs, not from memory. Institutions
(Stanford HAI) and different people who share a name are not counted.

## Secrets

`agentic-coding.md` contained a live Anthropic API key in plain text. It has
been removed from the file; make sure it was also revoked. Do not copy
credentials from the notes into the book, into examples, or into any file.
Example keys in the text must be obviously fake.

## Style of work

- Small, reviewable changes. One chapter at a time.
- Show the diff. Don't rewrite a file wholesale to make one edit.
- If a scripted edit asserts a match and the assertion fails, stop and report —
  don't loosen the pattern until something matches.
- Report what actually happened, including what didn't work. A verification
  script that finds nothing because it's broken is worse than no script; check
  that a check can fail before trusting it that it passed.
- Renaming a file removes the old path, so agents don't rename; suggest the
  `mv` and let the author run it.
- Before adding new material, find out what is new: compare `../literature/`
  against `references.bib` rather than assuming.
