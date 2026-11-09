# AI in Practice, or: How I Learned to Stop Worrying and Love the Agent

A toolbox and worked examples for biodiversity researchers. One day, HCMR,
November 2026. Taught from the book *AI for Biodiversity: A Primer*
(`../book/`), its five slide decks (this folder) and the hands-on companion
in `../workshop/`. All three are CC BY 4.0.

## The course and the book

The book is for ecologists, taxonomists, biodiversity informaticians and the
people who keep the databases running: readers who can write a script and
have been asked what they are doing about AI. Its subject is language models
and agents applied to biodiversity data and literature, with three arguments
running through it. The real change is the agent loop rather than the
chatbot, so the work moves from writing code to specifying it, limiting what
the agent can touch and checking what comes back. Data is the bottleneck,
and biodiversity informatics did most of that work over decades, so the
question is on what terms "AI-ready" data is now used. And running models on
your own machine is a reasonable choice for unpublished data, long-lived
infrastructure and work without a network. The title gives the day its
shape. The worry is an agent that reads files, runs code and writes results
on its own. Loving it, in the film's sense, means using it with your eyes
open: learn its loop, fence it in, read what it returns, and keep the
judgement with the ecologist. The course teaches the book in one day: two
lecture sessions on the landscape, the data and working with agents, a setup
session, a hands-on session in R with an invented springtail survey, a
weekly literature review and a model test, and a closing session on
security, integrity and keeping up. Every slide says only what the book says
and cites only its bibliography; the case that ecology is not ready for AI
is taught alongside the rest, not smoothed away.

## Before the day

- Bring a laptop with a terminal (macOS, Linux, or WSL on Windows), R and
  Git. Nothing was tested on Windows.
- Ideally install Ollama and one harness (OpenCode, Claude Code or Codex)
  beforehand, following `../workshop/SETUP.md`, and pull the model the
  companion names (`ollama pull gemma4:12b`, about 8 GB). Deck 0 walks
  through the same steps after lunch for anyone who has not.
- A 12B model at four bits needs about 8 GB of memory plus its context:
  16 GB runs it, 32 GB runs it comfortably. Without that, follow the
  hands-on session from the recorded runs in `../workshop/answers/`.
- Read Chapter 3 if you read one chapter before the day.

## Agenda

10:00 to 16:30, with two coffee breaks and one lunch break.

| Time | Session | Deck | Chapters |
|---|---|---|---|
| 10:00–10:10 | Welcome and goals of the day | — | Preface |
| 10:10–11:10 | **The landscape and the data.** Models, chatbots and agents; why now; what language models do well and how they fail; the ecology evidence; what "AI-ready" hides; organising and protecting your own data | 1 | 1–6 |
| 11:10–11:25 | Coffee | | |
| 11:25–12:25 | **Working with agents, and local-first.** The agentic workflow, rules files and memory in files; the software stack; reproducibility when a tool varies; the local-first case and its costs; KYBELE as a design; hardware; testing a model on your own task | 2 | 7–14 |
| 12:25–13:10 | Lunch | | |
| 13:10–13:40 | **Setting up.** Git, Ollama and a model, one harness; Git in ten commands; the controls every harness has. Participants run the two-minute check and copy `workshop/session` to a scratch folder | 0 | 8, 10, App. D |
| 13:40–15:00 | **The workshop, in action.** A first agent session on the invented springtail survey: rules as advice and as configuration, a checkpoint, the check script, the planted instruction in a data cell, the session log. The weekly literature review run offline on the fixture week. Testing a model with an answer key, a keyword baseline and a score. Local model steps take minutes on a laptop; the deck shows the recorded runs where a live one would be slow | 3 | 10, 11, 14 |
| 15:00–15:15 | Coffee | | |
| 15:15–16:05 | **Risk, integrity, keeping up, and the wider frame.** Running an agent is running arbitrary code; prompt injection and how to fence an agent in; sensitive localities; changes across the scientific workflow; what is worth learning; the epilogue; the checklists | 4 | 15–18, App. A–D |
| 16:05–16:30 | Discussion and close: what to tell colleagues | — | 17 |

An hour for a deck of 34 to 36 slides means some frames are shown rather
than taught; the paper and figure frames carry the argument, and the
outline frames can be passed over. The setup session assumes most
participants installed the tools beforehand; thirty minutes is enough to run
the check and fix the common failures, not to download a model. Deck order
1, 2, 0, 3, 4 puts the setup immediately before the session that uses it, so
that the morning stays on the ideas and installation problems surface after
lunch.

## Materials

- Book: `../book/main.pdf`. If you read one chapter, read Chapter 3.
- Slides: `0*-*/main.pdf` in this folder; each deck ends with its references.
- Companion: `../workshop/` (`README.md`, `SETUP.md`, `session/`,
  `literature/`, `testing/`, `answers/`). The data in `session/` and
  `testing/` are invented for teaching; do not publish or analyse them.
