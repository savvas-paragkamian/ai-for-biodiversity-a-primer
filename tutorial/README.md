# Agentic AI for Biodiversity: A Tutorial

A short companion to the book in `../book/` and the workshop in
`../workshop/`: 22 pages, about 5,500 words of prose, 25 listings and six
figures (11 November 2026). It is meant to be followed at a terminal.

| Part | Sections | Drawn from |
|---|---|---|
| I. The landscape, then coding | model, agent, harness, context; open or hosted; setup; a first taste; a first session; review | Chapters 1, 7, 8 and 10; `../workshop/SETUP.md`; `../workshop/session/` |
| II. Harvesting the literature | two layers; interests as queries; fetch; resolve; a clock and an assistant | Chapter 11; `../workshop/literature/` |
| III. The tools around a harness | what can be added; iChatBio; the Model Context Protocol; agents you add yourself; Git | Chapters 4, 5, 7 and 15; the tools' own documentation |

The method follows A. Murat Eren's tutorial *Agentic Coding and AI Synthesis
for Life Scientists* (`eren2026agenticcoding`; the PDF is in
`../../literature/`): open tools first, a real task, and an answer known
before the agent is asked. His tutorial runs to 36 pages; this one is kept
shorter on purpose.

## Build

Like the book: `pdflatex` and `biber`, no Makefile.

```bash
cd tutorial && latexmk -pdf main.tex     # clean with latexmk -C
```

`preamble.tex` loads the same packages as `../book/preamble.tex` and nothing
else. The bibliography is `../book/references.bib`; five of the six figures
are the book's PNGs from `../book/figures/png/`. Chapter numbers are macros
at the end of `preamble.tex`, so a renumbering of the book needs one edit.

The sixth figure, `figures/tut-tools`, was drawn for the tutorial in the
book's figure style. Rebuild it only when its source changes:

```bash
cd tutorial/figures/tikz
pdflatex -output-directory /tmp tut-tools.tex
cp /tmp/tut-tools.pdf ../tut-tools.pdf
pdftoppm -r 300 -png -singlefile ../tut-tools.pdf ../tut-tools
```

## Examples

The files in `examples/` are printed in the tutorial with `\lstinputlisting`,
so the PDF shows exactly what was tested. The head of the skill file is
printed the same way, from `../workshop/literature/.claude/skills/`.

| File | What it is | Tested on 11 November 2026 |
|---|---|---|
| `opencode.json` | the session's model and permissions (the workshop's file, one model, plus `autoupdate` and `share`) | loaded by OpenCode 1.17.11 without error |
| `opencode-mcp.json` | the InterPro MCP server as a block of `opencode.json` | `opencode mcp list` reported it connected; one question answered through it by a local model |
| `mcp.json` | the same server as Claude Code's `.mcp.json` | written by `claude mcp add -s project` (2.1.322); status "pending approval", not approved or used |
| `reviewer.md` | a read-only reviewer subagent for OpenCode | loaded and listed by `opencode agent list`; in one trial the main agent handed the review to it, and no report had come back after nine minutes with a local 27B model |
| `fetch_week.R` | one source, one topic, one week from Europe PMC | ran; one item |
| `check_doi.R` | Crossref check with a self-test that plants two errors | ran; `SELF-TEST PASSED` |
| `checklist_agent.py` | an iChatBio expert agent over a checklist | ran with `ichatbio-sdk` 0.2.8 on Python 3.12: served its agent card; answered in memory; never connected to iChatBio |

## What was and was not tested

All runs were made on 11 November 2026 by an AI agent (Claude Code) working
on the author's behalf, each once, on a MacBook Pro (Apple M1 Max, 32 GB)
with OpenCode 1.17.11, Ollama 0.40.15, Claude Code 2.1.322, R 4.5.1
(`httr2`, `jsonlite`) and Git 2.54.

- **Run:** the ten model answers of Section 4 (`phi4`, 14.7B, Q4_K_M;
  `qwen3.8:27b`, nvfp4, both at default sampling settings); the GBIF and
  iDigBio queries; both R scripts; the InterPro question through OpenCode
  with `qwen3.8:27b` (3 min 17 s); the Git sequence of Section 16, in a
  scratch copy of `../workshop/session/`.
- **Not run:** the first session itself (Section 5 reports the book's test
  runs of 11 October 2026); the installation commands (taken from
  `../workshop/SETUP.md`, dated 2 November 2026); `gemma4:12b`, which the
  configuration names but which was not installed on the day; iChatBio's web
  interface; the Claude Code subagent file, described from its
  documentation; anything on Windows. The reviewer subagent was tried once
  and did not report within nine minutes.
- **Found on the way.** OpenCode's documentation of 11 November 2026
  describes a newer configuration format (`permissions` as a list of rules,
  `mcp.servers`, `agents`); version 1.17.11 rejects `mcp.servers` as
  invalid, and the published schema marks the older keys, which this
  tutorial and the workshop use, as deprecated. `opencode run` waited
  without output when its standard input was not a terminal, until it was
  given `< /dev/null`. The installed SDK's `run` method takes a `metadata`
  argument that its README example omits.

Commands and tool behaviour come from the tools' own documentation and
`--help`, read on 11 November 2026: <https://opencode.ai/docs/> (MCP servers,
agents), <https://opencode.ai/config.json>, <https://code.claude.com/docs/en/mcp>,
<https://code.claude.com/docs/en/sub-agents>,
<https://ebi-pf-team.github.io/interpro-mcp/connecting.html> and
<https://github.com/acislab/ichatbio-sdk> (README; MIT; version 0.2.8 on
PyPI). They are not bibliography entries.

## Checks

A second agent, given only the text and the sources, checked about 135
attributed claims against Eren's PDF, the iChatBio abstract, the book and
the workshop on 11 November 2026. It found 21 places where the text said
slightly more than its source or altered a line in a listing marked
"shortened"; all were corrected, and the prompts, numbers and dates it
checked matched. Both agents ran on the same model, so this is a second
reading, not an independent referee.

The book's rules apply (`../AGENTS.md`): every citation is an entry of
`../book/references.bib`, British spelling, sentences under 35 words. The
check scripts read `book/chapters/`; they were run on this text through a
wrapper that points them at `main.tex`. Result on 11 November 2026: zero
build errors, no `biber` warnings, no banned words, and two 8-word matches
with the literature folder, both quotations from Eren in quotation marks.

## Licence

CC BY 4.0, like the book. Written with AI agents from the book's text; the
title page says "Draft" until the author has checked it.
