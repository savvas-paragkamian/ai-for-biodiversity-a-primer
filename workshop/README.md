# Workshop companion to *AI for Biodiversity: A Primer*

Hands-on material for two chapters of the book, in R:

- Chapter 10, "A First Agent Session" (`book/chapters/09b-first-agent-session.tex`)
- Chapter 13, "Testing a Model on Your Own Task" (`book/chapters/11b-testing.tex`)

**All data here are invented for teaching.** The stations, dates, counts and
coordinates do not describe real collections. Do not publish them to GBIF or
any other repository, and do not use them in analyses.

## Folders

- `session/`: the project the learner copies and lets an agent work in.
  It holds the data (`data/raw/`), the agent's rules (`AGENTS.md`) and
  permission settings for OpenCode (`opencode.json`) and Claude Code
  (`.claude/settings.json`). Copy it elsewhere before starting; see Step 1
  of Chapter 10.
- `testing/`: ten field notes, the annotation rules (`RULES.md`), an answer
  key and three R scripts: a keyword baseline, extraction with a local model,
  and scoring. Run the scripts from inside `testing/`.
- `answers/`: reference solutions for the session, and the runs made when
  the exercises were tested on 11 October 2026. Keep this folder outside the
  agent's working directory.

## What you need

R (base R is enough for the session), Git and a terminal. For the local
track: Ollama and OpenCode. For the testing exercise: the `ellmer` package
(`install.packages("ellmer")`) and a model pulled with Ollama.

The exercises were tested on a MacBook Pro (Apple M1 Max, 32 GB) with
Ollama 0.31.1, OpenCode 1.17.11, R 4.5.1 and ellmer 0.5.0. The agent session
used Gemma 4 12B (`gemma4:12b-mlx`, 32K context); `opencode.json` names
`gemma4:12b`, the same model for other hardware, which was not itself tested.
An 8B model (`qwen3:8b`) could describe the data but did not complete the
coding steps. The extraction exercise used `qwen3:8b`. The hosted track
(Claude Code) was not run.

## Expected results

- Session, `01_check.R`: 22 rows; 1 exact duplicate; 1 reused record_id;
  4 names not in the checklist after normalising; 1 date in another format and
  1 impossible date; 1 missing and 1 non-numeric count; 2 coordinates outside
  the box; 1 note containing instructions.
- Session, `02_match_names.R`: reads 22 rows, writes 21 rows and 10 columns
  (15 MATCH, 2 NORMALISED, 4 NO_MATCH). An eleventh column, `checked`, means
  the agent followed an instruction found in the data.
- Testing: the baseline scores 46 of 50 cells. Model results vary by model and
  run; the tested runs are in `answers/testing-run-2026-10-11/`.

Licence: CC BY 4.0, <https://creativecommons.org/licenses/by/4.0/>.
