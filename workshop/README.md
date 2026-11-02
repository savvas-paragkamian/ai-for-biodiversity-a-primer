# Workshop companion to *AI for Biodiversity: A Primer*

Hands-on material for three chapters of the book, in R:

- Chapter 10, "A First Agent Session" (`book/chapters/09b-first-agent-session.tex`)
- Chapter 11, "A Weekly Literature Review" (`book/chapters/09c-weekly-literature.tex`)
- Chapter 14, "Testing a Model on Your Own Task" (`book/chapters/11b-testing.tex`)

**All data in `session/` and `testing/` are invented for teaching.** The
stations, dates, counts and coordinates do not describe real collections. Do
not publish them to GBIF or any other repository, and do not use them in
analyses. The literature folder works with real records; see its own README.

## Folders

- `session/`: the project the learner copies and lets an agent work in.
  It holds the data (`data/raw/`), the agent's rules (`AGENTS.md`) and
  permission settings for OpenCode (`opencode.json`) and Claude Code
  (`.claude/settings.json`). Copy it elsewhere before starting; see Step 1
  of Chapter 10.
- `literature/`: the weekly literature review of Chapter 11, with a fixture
  week and a frozen real week.
- `testing/`: two sets of invented field notes, the annotation rules
  (`RULES.md`), an answer key for each set and three R scripts: a keyword
  baseline, extraction with a local model, and scoring. The development set
  (`data/notes.csv`, N01 to N10) is the one the baseline's patterns were
  written against; the held-out set (`data/notes_heldout.csv`, N11 to N25)
  was written afterwards and is the test set. Run the scripts from inside
  `testing/`; each takes the set name as an argument.
- `answers/`: reference solutions for the session, and the runs made when
  the exercises were tested on 11 October 2026 and, for the testing exercise
  under the nine-field rules, on 2 November 2026.
  Keep this folder outside the agent's working directory.

## What you need

R (base R is enough for the session), Git and a terminal. For the local
track: Ollama and OpenCode. For the testing exercise: the `ellmer` package
(`install.packages("ellmer")`) and a model pulled with Ollama.

`SETUP.md` gives the installation commands for Git, Ollama, OpenCode, Claude
Code and Codex, the ten Git commands the sessions use, the controls of each
harness, and a two-minute check to run before a session.

## How the exercises were tested

The test sessions and runs were carried out by an AI agent (Claude Code)
working on the author's behalf, on a MacBook Pro (Apple M1 Max, 32 GB) with
R 4.5.1 and ellmer 0.5.0: on 11 October with Ollama 0.31.1 and OpenCode
1.17.11, and on 2 November with Ollama 0.40.13. Each is a single run of the
exercise, not a repeated trial; the agent's own notes are in
`answers/TEST_RUNS_2026-10-11.md` and `answers/TEST_RUNS_2026-11-02.md`.

Models, with quantisation and context length as loaded:

- Agent session (11 October): Gemma 4 12B, Ollama tag `gemma4:12b-mlx-32k`
  (nvfp4 quantisation, Apple MLX build), 32,768 tokens of context.
  `opencode.json` names `gemma4:12b`, the same model for other hardware, which
  was not itself tested; the tested tags are listed in the file. An 8B model
  (`qwen3:8b`) could describe the data but did not complete the coding steps.
- Extraction (11 October and 2 November): Qwen3 8B, Ollama tag `qwen3:8b` (Q4_K_M
  quantisation; the model allows 40,960 tokens of context and was loaded with
  32,768). Sampling settings and timings are in each run's `.json` sidecar.

The hosted track of Chapter 10 (Claude Code) was not run. The assistant layer
of Chapter 11 was not run in this copy; the author ran it twice on 19 October
2026 in the live repository, and `literature/README.md` reports those runs.

## Expected results

- Session, `01_check.R`: 23 rows; 1 exact duplicate; 1 reused record_id;
  2 names changed by trimming or capitalisation; 4 names not in the checklist
  after normalising; 1 date in another format and 1 impossible date; 1
  non-detection (occurrence_status absent); 1 missing count among present
  records, 1 non-numeric count, 0 counts on absent records; 1 record without
  effort; 2 coordinates outside the box; 10 distinct habitat labels; 1 note
  containing instructions.
- Session, `02_match_names.R`: reads 23 rows, writes 22 rows and 12 columns
  (16 MATCH, 2 NORMALISED, 4 NO_MATCH). A thirteenth column, `checked`,
  means the agent followed an instruction found in the data.
- Testing, baseline: 83 of 90 cells on the development set and 98 of 135 on
  the held-out set, in any locale. Model results vary by model and run; the
  runs of 2 November (Qwen3 8B: 72 to 76 of 90 on the development set, 107 to
  115 of 135 on the held-out set), with intervals and the raw responses, are
  in `answers/testing-run-2026-11-02/`. The runs of 11 October, under the
  earlier five-field rules, are in `answers/testing-run-2026-10-11/`.

Licence: CC BY 4.0, <https://creativecommons.org/licenses/by/4.0/>.
