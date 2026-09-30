# AI for Biodiversity — A Primer

LaTeX source. Built from `../NOTES.md` (the outline), the other notes in the
parent directory, and the papers in `../../literature/`.

## Scope

For ecologists, taxonomists, biodiversity informaticians and the people who
keep the databases running: readers who can write a script and have been asked
what they are doing about AI. Not for machine learning researchers.

The subject is language models and agents applied to biodiversity data and
literature: what they are, what they do well and badly, how to work with them
safely, and how to run them on your own hardware. Image, sound and species
distribution models appear only briefly, in Chapter 4.

Three arguments run through it:

1. **The real change is the agent loop, not the chatbot.** The job moves from
   writing code to specifying it, limiting what it can touch and checking what
   comes back.
2. **Data is the bottleneck, and biodiversity informatics did most of the work.**
   "AI-ready" data is decades of curation by people; the book asks on what terms
   it is now used.
3. **Running models locally is a reasonable choice** for unpublished data,
   long-lived infrastructure and work without a network.

The book does not argue for or against adoption. The case that ecology is not
ready (`mishra2026notready`) is represented throughout, as are other dissenting
views.

**Running example.** KYBELE, a literature assistant for Collembola built on the
SIB Literature Services, is the worked example of biodiversity literature and
knowledge retrieval (Chapter 10). It is being expanded; at the time of writing
its serving layer runs and its orchestrator is designed but not built.

## Contents

About 16,000 words, 73 pages.

| Part | Chapters |
|---|---|
| Preface | Audience, the three arguments, how the book was written |
| I. The Landscape | 1 Chatbots, Models and Agents · 2 Why Now? · 3 Powers and Limitations · 4 Applications in Biology and Ecology |
| II. Data | 5 AI-Ready Data · 6 Organising and Protecting Your Data |
| III. Working with Agents | 7 The Agentic Coding Workflow · 8 The Software Stack · 9 Reproducibility When the Tool Varies |
| IV. Local-First | 10 The Local-First Approach (with the KYBELE example) · 11 Hardware for Local Inference |
| V. Risk, Integrity and Keeping Up | 12 Security, Biorisk and Governance (ending in the wider frame: noosphere, evolvable AI) · 13 Changes Across the Scientific Workflow · 14 How to Keep Up |
| Appendices | A Glossary · B Checklists · C Tutorials (videos, newsletters, blogs, awesome lists, tool repositories) · D State of Play, September 2026 (prices, model versions, harnesses, usage limits) |

If you read one chapter, read Chapter 3.

The chapters are written to last; names, prices and limits that will date live
in Appendix D, and links that will rot live in Appendix C.

## Build

Needs TeX Live with `pdflatex` and `biber`.

```bash
latexmk -pdf main.tex        # build
latexmk -pdf -pvc main.tex   # rebuild on save
latexmk -C                   # clean, including the PDF
```

By hand, if you prefer: `pdflatex` -> `biber main` -> `pdflatex` -> `pdflatex`.

## Layout

```
main.tex          parts and chapter includes
preamble.tex      packages, formatting, biblatex setup
references.bib    116 entries, grouped by theme
chapters/
  00-preface
  01-landscape  02-why-now  03-powers-and-limits  04-applications
  05-ai-ready-data  06-organisation-and-backup
  07-agentic-workflow  08-software-stack  09-reproducibility
  10-local-first  11-hardware
  12-security-and-biorisk  13-scientific-workflow  14-keeping-up
  A1-glossary  A2-checklists  A3-tutorials  A4-state-of-play
```

## Bibliography

Assembled from the `.bib`, `.ris` and `.bibtex` files in `../../literature/`,
plus entries taken from the PDFs there.

Verified: all 48 DOIs resolve through Crossref and all 28 arXiv IDs through the
arXiv API, titles matching in every case. The remaining 40 entries are reports,
books, blog posts and web pages with no such identifier, checked by hand. Every
entry is cited at least once.

Videos, newsletters, blogs and code repositories are not bibliography entries;
they are listed in Appendix C, with names checked against YouTube, GitHub and
the publishers' own sites.

## Checks

Run from the repository root. Each has a `--self-test` that plants errors and
confirms they are caught. Needs `pandoc`, `pdftotext` and `hunspell`.

```bash
python3 scripts/verify_bib.py          # every DOI and arXiv ID resolves, titles match
python3 scripts/check_plagiarism.py    # 8-word verbatim overlap with ../literature
python3 scripts/check_language.py      # British spelling, banned words, long sentences
```

The last two produce lists to read, not verdicts: names, numbers and your own
notes will match.

## Open issues

The linguistic revision was completed on 30 September 2026. See
[`LINGUISTIC_REVISION.md`](../LINGUISTIC_REVISION.md) for changes and checks.
The author's thesis informed paragraph structure and flow only; it was not
used as a factual source.

- `openai2026huggingface` is cited in Chapters 5 and 12 for model files carrying
  executable payloads; the source is about agents escaping a sandbox. Those two
  sentences need another source or rewording.
- KYBELE's expansion as the running example needs its design documents in
  `../../literature/` before it can be written up.
- Seth (2026) has a citation file in `../../literature/` but no PDF, so it is
  not cited.

## Conventions

See `../AGENTS.md`. Briefly: minimal formatting, plain words over jargon, at most
one `keypoint` box per chapter, no table that restates the prose beside it, and
no citation to anything not sitting in `../../literature/`.

Read [`WRITING_STYLE.md`](../WRITING_STYLE.md) before drafting or revising prose.
It is the author's reusable guide to paragraph structure, rhythm and tone.
