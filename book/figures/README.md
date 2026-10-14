# Figures

Forty-one diagrams, two or three per chapter, drawn in TikZ and built into
three formats from one source. They are meant to be reused in the workshop
slides as well as in the book.

```
figures/
  style.tex       the shared style: fonts, line width, node shapes, colours
  tikz/NAME.tex   one source per figure
  pdf/NAME.pdf    vector, what pdflatex drew
  png/NAME.png    300 dpi, what the book includes (preamble: \fig{NAME})
  svg/NAME.svg    for slides; text converted to outlines, so it looks the
                  same on a machine without Latin Modern
```

## Building

From the repository root:

```bash
scripts/build_figures.sh              # every figure
scripts/build_figures.sh ch01-agent-loop   # one figure
```

Each `tikz/NAME.tex` is compiled with `pdflatex` (standalone class), then
rendered with `pdftoppm` (PNG) and `pdftocairo` (SVG), both from poppler. The
script prints each figure's size in points; the text width of the book is
427 pt, and `\fig` scales a wider figure down to fit, so keep figures at or
under about 440 pt wide. The build directory is temporary; only `pdf/`,
`png/` and `svg/` are written.

No SVG rasteriser on this machine could typeset Latin Modern correctly
(ImageMagick's built-in renderer dropped strokes; Quick Look cannot see
TeX's fonts), which is why the sources are TikZ and the SVG is derived from
the PDF rather than the other way round.

## Style

The look follows Knuth's own figures: Latin Modern, thin black lines,
small capitals for panel titles, no decoration.

- Line width 0.6 pt; arrowheads `Stealth`, 5 pt.
- `\small` for labels, `\footnotesize` for annotations; italic
  (`note`) for commentary, upright (`tag`) for labels, `\ttfamily` for
  file names and commands.
- Two colours besides black: `lightgrey` (gray 0.92) fills a box that is
  the subject of the figure (the model, the raw data, the rules), and
  `accent` (#9B2D20) marks what is untrusted, wrong or missing. Use the
  accent in at most one place per figure, and only when the point needs it.
- Flowcharts in the TAOCP manner: rectangles for steps, diamonds for
  decisions, rounded boxes for start and end.
- Node styles are in `style.tex`: `box`, `grey`, `rounded`, `decision`,
  `group` (dashed, for grouping), `tag`, `note`, `code`, `title`, `badbox`.
- No hyphenation inside boxes (`\hyphenpenalty=10000` in the style).

## Adding a figure

1. Copy a similar `tikz/*.tex`, keep `\input{../style}`, and name the file
   `chNN-topic.tex` with the chapter number the figure belongs to.
2. Build it, open the PNG, and check the width printed by the script.
3. Include it in the chapter with `\fig{chNN-topic}` inside a `figure`
   environment, give it a caption that says what the picture shows, a
   `fig:*` label, and a `\Cref` in the prose. A figure nobody refers to is
   clutter.
4. Add it to the index below.

## Index

| Figure | Chapter | Label | What it shows |
|---|---|---|---|
| ch01-two-lineages | 1 | fig:lineages | The information utility and Unix as the two patterns frontier and local models repeat |
| ch01-model-chatbot-agent | 1 | fig:modelchatbotagent | The same model with a buffer and a web page, or with tools, a loop and a harness |
| ch01-agent-loop | 1 | fig:agentloop | The pseudocode of the agent loop as a flowchart |
| ch02-parallel-sequential | 2 | fig:parallel | Training every position at once; generating one token at a time |
| ch02-open-closed-gap | 2 | fig:gap | The lead of the best closed model over the best open-weight one, 2023 to March 2026 (AI Index) |
| ch03-guessing-wins | 3 | fig:guessing | Why a test that scores accuracy alone rewards guessing |
| ch03-sycophancy-loop | 3 | fig:spiral | The delusional spiral and the four places to break it |
| ch03-context-window | 3 | fig:context | The context window growing over three turns |
| ch04-two-ways-to-ask | 4 | fig:twoways | Reading from a supplied text against recalling from the weights |
| ch04-sampling-bias | 4 | fig:samplingbias | A model trained on biased records predicts where people looked |
| ch04-curation-loop | 4 | fig:curation | The model suggests, the curator decides, the knowledgebase feeds every analysis |
| ch05-commons | 5 | fig:commons | The data commons and the return arrow that is not guaranteed |
| ch05-mcp | 5 | fig:mcp | One adapter per pair against one wrapper per resource |
| ch05-rag-pipeline | 5 | fig:rag | The six steps of retrieval-augmented generation and the seven failure points |
| ch06-raw-readonly | 6 | fig:rawreadonly | Raw data read-only, everything else derived by script |
| ch06-backup | 6 | fig:backup | 3-2-1 backup, and why RAID is not one |
| ch07-chop | 7 | fig:chop | Chat-oriented programming with the check in the loop; vibe coding without it |
| ch07-chatbot-vs-harness | 7 | fig:harnessloop | Where the loop runs: through you, or inside the project |
| ch07-task-size | 7 | fig:tasksize | One big task against a series with review points |
| ch08-layers | 8 | fig:layers | The software stack and the four interfaces |
| ch08-local-tooling | 8 | fig:localtooling | Clients, API, runtimes and engine for local models |
| ch08-speech | 8 | fig:speech | Speech to text with the filters around Whisper |
| ch09-chain-of-inference | 9 | fig:chain | Generated code is kept; a generated number is not |
| ch09-variation | 9 | fig:variation | Five sources of variation in a model call and the remedy for each |
| ch10-session-flow | 10 | fig:session | The first agent session as a flowchart with its checks |
| ch10-three-layers | 10 | fig:threelayers | Rules file, harness configuration and file permissions around the raw data |
| ch11-where-data-goes | 11 | fig:datagoes | Which ways of using a model send the data out of the institution |
| ch11-architecture | 11 | fig:architecture | Interface, proxy, routing, runtime, retrieval and archive |
| ch11-kybele | 11 | fig:kybele | KYBELE's clients, orchestrator, literature service and model, as designed |
| ch12-memory-bandwidth | 12 | fig:memory | Every weight is read once per token; the model must fit first |
| ch12-unified-memory | 12 | fig:unified | A separate graphics card against a shared memory pool |
| ch12-size-guide | 12 | fig:sizes | Model sizes on a logarithmic scale and the tasks each range serves |
| ch13-procedure | 13 | fig:procedure | The six-step testing procedure |
| ch13-scoring-grid | 13 | fig:scoring | Correct, wrong, missed and invented values in a 2 by 2 grid |
| ch14-injection | 14 | fig:injection | Instructions and data as one stream of tokens |
| ch14-fences | 14 | fig:fences | Five layers around an agent, each with its limit |
| ch14-shared-layer | 14 | fig:sharedlayer | Both refusals live in the instruction-tuning layer that injection subverts |
| ch15-workflow-checks | 15 | fig:workflow | Five stages of the research workflow, the use and the limit at each |
| ch15-resolve | 15 | fig:resolve | Resolving every reference before it enters a manuscript |
| ch16-routine | 16 | fig:routine | Weekly, monthly, quarterly and yearly slots adding up to forty hours |
| ch16-small-project | 16 | fig:smallproject | Retrieval over your own reprints and the three lessons it teaches |

Chapter numbers are those of the built book (Chapter 10 is
`09b-first-agent-session.tex`, Chapter 13 is `11b-testing.tex`); the file
prefix `chNN` follows the same numbering.
