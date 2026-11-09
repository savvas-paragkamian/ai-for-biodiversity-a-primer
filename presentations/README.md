# Workshop slides: *AI in Practice, or: How I Learned to Stop Worrying and Love the Agent*

The workshop's title (chosen 6 November 2026) is on every title page, with
the subtitle *A toolbox and worked examples for biodiversity researchers,
from the book* AI for Biodiversity: A Primer.

Four Beamer decks of about thirty slides each, built from the book in
`../book/`, and a shorter setup deck (deck 0) taught before the hands-on
sessions. They are for the HCMR workshop and for teaching the same material
to the KYBELE team. Everything on decks 1 to 4 comes from the book: the text
is the book's, the figures are the book's TikZ figures, and the only
citations are entries of `../book/references.bib`. Deck 0 is the exception:
its installation commands and harness controls come from the tools' own
documentation and `--help`, read on the date each slide states.

| Deck | Folder | Covers |
|---|---|---|
| 0 | `00-setup/` | Setting up before the hands-on sessions: installing Git, Ollama, OpenCode, Claude Code and Codex; Git in ten commands; the controls of a harness (model, effort, context and usage, permissions, one-shot runs, rules and memory files). Same text, for copying, in `../workshop/SETUP.md` |
| 1 | `01-landscape-and-data/` | Part I, The Landscape (Chapters 1–4) and Part II, Data (Chapters 5–6) |
| 2 | `02-agents-and-local-first/` | Part III, Working with Agents (Chapters 7–11) and Part IV, Local-First (Chapters 12–14) |
| 3 | `03-workshop-walkthrough/` | The three hands-on exercises in action: Chapters 10, 11 and 14 with the companion in `../workshop/` |
| 4 | `04-risk-and-keeping-up/` | Part V, Risk, Integrity and Keeping Up (Chapters 15–18) and the appendices |

`AGENDA.md` is the one-day programme, in deck order 1, 2, 0, 3, 4, with a
paragraph describing the course and the book.

The structure follows Stanford's CME 295 lectures (in `../../literature/standford-class/`):
goals, an outline repeated at each section, one idea per slide, a running
example, and takeaways at the end. Twenty-three important sources (papers,
reports and two web pages) appear as a screenshot of their first page beside
what the book takes from them, with the source line underneath.

## Build

Each deck builds on its own, with `pdflatex` and `biber`, like the book:

```bash
cd presentations/01-landscape-and-data && latexmk -pdf main.tex
```

`common/preamble.tex` holds the shared style and macros (`\fig`,
`\paperslide`, `\screenshot`, `\source`, `\kp`, `\code`, `\term`). The figures
are read from `../book/figures/pdf/` and the paper screenshots from
`common/screenshots/`, where each is named by its bibliography key.

## Screenshots

`common/screenshots/<key>.png` is page 1 of the paper's PDF in
`../../literature/`, rendered with `pdftoppm -r 110 -f 1 -l 1 -png`. The four
added on 6 November 2026 (`pombase2026curation`, `apertus2026report`,
`jiralerspong2026slopcliff`, `anthropic2026aiforscience`) were made the same
way, as were the four added on 9 November 2026 for deck 1's frames on how the
founders of the field worked (`thompson1905aberdeen`, `fisher1926arrangement`,
`tukey1962future`, `michener2012ecoinformatics`); the Fisher and Michener
files open with two sheets added by the repository or publisher, so their
screenshots are page 3 of the PDF, the paper's own first page, and the Fisher
scan is cropped to the text block to leave out a black strip from scanning
(`-x 245 -y 0 -W 660 -H 1060`). `common/preamble.tex` drops the `note` field from cite commands, so a
`\fullcite` source line does not print how a web page was saved. They are shown for
teaching, with the full reference under each; check the publisher's terms
before distributing the slides outside the workshop.

## Licence

CC BY 4.0, like the book. Written with AI agents from the book's text; the
author checks every slide.
