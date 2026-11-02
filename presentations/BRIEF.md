# Brief for the agents writing the workshop decks (2 November 2026)

Four Beamer decks, about thirty slides each, teach the book
*AI for Biodiversity: A Primer* (`book/`) at an HCMR workshop; the same
material is taught to the KYBELE team. One agent writes one deck. You own
only your deck's folder under `presentations/`; you edit nothing else.

| Deck | Folder | Chapters (file under `book/chapters/`) |
|---|---|---|
| 1 | `01-landscape-and-data` | Part I: 1 `01-landscape`, 2 `02-why-now`, 3 `03-powers-and-limits`, 4 `04-applications`. Part II: 5 `05-ai-ready-data`, 6 `06-organisation-and-backup` |
| 2 | `02-agents-and-local-first` | Part III: 7 `07-agentic-workflow`, 8 `08-software-stack`, 9 `09-reproducibility`, 10 `09b-first-agent-session`, 11 `09c-weekly-literature`. Part IV: 12 `10-local-first`, 13 `11-hardware`, 14 `11b-testing`. Chapters 10, 11 and 14 get one or two frames each here, because deck 3 walks through them |
| 3 | `03-workshop-walkthrough` | The three exercises in action: Chapter 10 `09b-first-agent-session`, Chapter 11 `09c-weekly-literature`, Chapter 14 `11b-testing`, with the companion `workshop/` (its `README.md`, `session/`, `literature/`, `testing/`, `answers/`). Commands, rules files, prompts, expected results, and what went wrong in the test runs |
| 4 | `04-risk-and-keeping-up` | Part V: 15 `12-security-and-biorisk`, 16 `13-scientific-workflow`, 17 `14-keeping-up`, 18 `14b-epilogue`. Appendices: `A1-glossary`, `A2-checklists`, `A3-tutorials`, `A4-state-of-play` |

Chapter numbers are those of the built book; the file names lag behind.

## Read first, in this order

1. `AGENTS.md`, the sections **Never**, **Prose**, **Formatting** and
   **Decisions already made**. The house rules apply to the slides.
2. `WRITING_STYLE.md`, for tone.
3. `presentations/README.md`, `presentations/common/preamble.tex` (the macros),
   and your deck's `main.tex`, which is a skeleton with placeholder frames to
   replace. Keep the title frame's fields, the `\section` structure and the
   References frame at the end.
4. Your chapters, in full. `book/main.pdf` shows the figures in place.
5. The model for the style of a lecture:
   `../literature/standford-class/fall26-cme295-lecture1.pdf` (read it with
   `pdftotext`, or render a few pages with `pdftoppm -r 40 -png` and look at
   them). Take from it: a goals slide, an outline repeated at each section
   with the current one highlighted (the preamble does this at every
   `\section`), one concept per slide, a paper's first page beside what is
   taken from it with a source line, a running example, takeaways at the end.

## Shape of a deck

1. Title frame (`[plain]`, already there).
2. "Goals of this session": two or three numbered goals.
3. One `\section` per chapter (or per pair of short chapters), three to six
   frames each, more where the chapter has figures. The outline frames are
   generated.
4. A running example where the chapter allows one: the invented Collembola
   survey of `workshop/session` (Chapter 10) and KYBELE as Chapter 12
   describes it, a design, not a running system.
5. "Takeaways": four to six bullets, in the book's words. Deck 4 also shows
   the "What to tell colleagues" quotation from Chapter 17.
6. References: the frame at the end, `allowframebreaks`, lists every key cited.

Target: about 30 pages in the PDF (26 to 34), counting the outline frames the
preamble generates. Check with `pdfinfo main.pdf`.

## Rules

- **Material from the book only.** Every statement on a slide comes from
  your chapters, in the book's words or a close paraphrase, with the book's
  hedges and attributions kept. Add no facts, numbers or examples from
  memory. Dissent stays in: Mishra (Ch. 4 and 17), Wickham (Ch. 12),
  Mitchell against Bengio (Ch. 15), the one-figure rule notwithstanding.
- **Cite only keys that exist in `book/references.bib`**, and only for the
  claim the book cites them for. Use `\parencite{key}` on the slide. Nothing
  else may be cited, and nothing may be cited from memory.
- **KYBELE:** only what Chapter 12 says. Never write KYBELE features or
  results by inference. It is "KYBELE: a design".
- **Prose:** British spelling, `-ise`. Plain words. Not "cutting-edge",
  "leverage", "revolutionary", "it's worth noting", "delve", "load-bearing".
  One idea per frame; at most six bullets or about eight lines of text;
  bullets are short sentences or phrases. Numbers only where they change
  what the listener would do.
- **Figures:** use the book's figures for your chapters, by name:
  `\fig{chNN-name}` (the index is in `book/figures/README.md`; the PDF
  versions are found automatically). Use most of them; a figure the book
  refers to is a slide in waiting. Put `\source{Figure from Chapter N of the
  book.}` under each, or a one-line caption in the same place.
- **Paper screenshots:** the first pages are pre-rendered in
  `presentations/common/screenshots/<key>.png`. Use
  `\paperslide{key}{<bullets of what the book takes from it>}` followed by
  `\source{\fullcite{key}}`. Each deck shows the papers assigned to it, and
  no others; do not render new screenshots.
  - Deck 1: `vaswani2017attention`, `mishra2026notready`,
    `mammides2026llmecology`, `keck2026interactions`, `wieczorek2012darwincore`.
  - Deck 2: `becker2025metr`, `piskala2026files`, `kleppmann2019localfirst`,
    `carli2026karenina`.
  - Deck 3: `zhao2026citations`; it may also reuse `keck2026interactions` and
    `carli2026karenina`.
  - Deck 4: `greshake2023injection`, `shapira2026agentsofchaos`,
    `lindenmayer2017donotpublish`, `seth2026naturalism`, `muller2026evolvableai`.
- **Code:** copy listings from the book or from the workshop files word for
  word, in a `[fragile]` frame with `\begin{lstlisting}[style=shell]` or
  `\begin{lstlisting}`. Keep a listing under about twelve lines; cut with a
  comment line `# ...` and say what was cut.
- **Tables:** only the book's own tables (Chapters 1, 12, 16, 17, Appendix D),
  and only where they help on a slide; `booktabs` and `tabularx` are loaded.
- **No new packages** and no changes to `common/preamble.tex`. If it needs a
  change, say so in your report.
- **Never delete files. Never commit.** Edit nothing outside your deck's
  folder. Do not write into `workshop/` or `book/`.
- **Deck 3 only:** you may run the scripts that need no model, on a copy of
  `workshop/` made under `$CLAUDE_JOB_DIR/tmp/` (the testing baseline
  `R/01_baseline.R` and scorer `R/03_score.R` over the existing results, and
  `answers/solutions/01_check.R` on a copy of `session/`), to show real
  output on a slide. Do not run a model, an agent, OpenCode, Claude Code or
  `claude -p`; quote their recorded outputs from `workshop/answers/` and the
  chapters instead. macOS has no `timeout`; `ellmer` is not installed and is
  not needed for these scripts.

## Build and check

```bash
cd presentations/<deck> && latexmk -pdf main.tex
grep -c '^!' main.log          # must be 0
grep -i warn main.blg          # must be empty
grep -c 'Overfull' main.log    # report the count; fix any over 2pt
pdfinfo main.pdf | grep Pages  # 26 to 34
```

Then look at the result. Render the pages (`pdftoppm -r 40 -png main.pdf
$CLAUDE_JOB_DIR/tmp/<deck>`), tile them into one image with PIL, and view it.
Fix frames whose text runs off the bottom, and frames that are a wall of
text. Finally, grep your `main.tex` for banned words and American spellings:

```bash
grep -n -i -E "cutting-edge|leverage|revolutionar|worth noting|delve|load-bearing|color\b|organiz|analyz|optimiz|behavior|center\b" main.tex
```

## Report back, briefly

1. Page count, and the list of frame titles in order.
2. The figures and the papers used; any assigned paper you left out, and why.
3. The build output: errors, biber warnings, overfull boxes.
4. What you left out of the chapters, and anything you were unsure how to
   represent faithfully.
5. Any change you think the shared preamble needs.
