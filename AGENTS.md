# AGENTS.md

Conventions for agents working in this repository. Written in response to things
that have actually gone wrong. Read before editing.

## What this is

A LaTeX textbook, `book/`, called *AI for Biodiversity: A Primer*. Source material
is the Markdown notes in this directory and the papers in `../literature/`.

`NOTES.md` is the outline the book follows. Treat it as the table of contents:
if you add a chapter, it should correspond to something there, and if you find
yourself wanting a section that isn't in `NOTES.md`, say so rather than
inventing one.

## Start here

Any agent, any harness. Read in this order before changing anything:

1. This file, all of it. Then **Decisions already made** and **Open work**
   near the end, so you don't reopen settled questions or duplicate work.
2. `book/README.md`: scope, contents by part and chapter, and open issues.
3. `NOTES.md`: the outline.
4. The chapter you are about to touch, in full.

You need `latexmk`, `biber`, `pdftotext`, `pandoc` and `hunspell`, and network
access for `verify_bib.py` (Crossref and the arXiv API). If you can't run a
check, say so in your report. Don't claim it passed.

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
minutes and there is no acceptable reason to skip it. There are 179 entries:
all 86 DOIs and all 52 arXiv IDs currently pass, and 41 entries have neither and
were checked by hand. Grant DOIs (CORDIS, `10.3030/...`) carry their title in
Crossref's `project` field; the script handles that. Each script in `scripts/`
has a `--self-test` that plants errors; run it after changing a script.

- **A citation file is not a source.** Seth's article and the Richards and
  Agüera y Arcas commentary are now cited from
  `conscious-artificial-intelligence-and-biological-naturalism.pdf`, supplied
  on 10 October 2026. The commentary is on pages 76–77 of that combined PDF;
  no separate commentary PDF is needed.
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

Read `WRITING_STYLE.md` before drafting or revising prose. The author requested
that the author's writing sample inform structure and flow only, never factual content or
citations. The reusable guide records that preference.

The book is for working ecologists, taxonomists and biodiversity
informaticians, not for machine learning researchers.

- **Plain words over jargon.** Not "binding constraint", "load-bearing",
  "compositional", "posture", "leverage", "second-order effects", "substrate",
  "defensible". Say what you mean. If a term is genuinely technical and the book
  needs it, define it on first use and add it to the glossary.
- **British spelling**, Oxford-style `-ise`.
- **Don't hedge and don't inflate.** No "it's worth noting", no "cutting-edge",
  no "revolutionary".
- **Attribute claims.** A factual assertion either cites a source in the
  bibliography or is clearly framed as the author's judgement.
- **More than one citation per statement is fine.** Cite every source that
  supports a sentence: a primary statement with its ecological application,
  a finding with its replication, or both sides of a disagreement. Each
  source must support the sentence by itself; do not add one to pad a list.
  Adding a citation to an existing sentence is usually better than adding
  new prose.
- **One figure per study.** When summarising a study, keep the one figure
  that carries the lesson and leave the rest to the source; a reader who
  wants the others can open it. Results of the book's own exercises are
  exempt, because readers compare their runs with them. Author's decision,
  11 October 2026.
- **Dissent stays in.** `mishra2026notready` argues ecology isn't ready for AI.
  That argument is represented fairly throughout and is not to be smoothed away.
  The same holds elsewhere: Mitchell and Bengio read the 2026 agent incidents
  differently (`12-security-and-biorisk.tex`), and Wickham's view that local models are not
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
- Figures: 41 diagrams, two or three per chapter (none in the preface or the
  appendices), drawn in TikZ under `book/figures/tikz/` and included as 300 dpi
  PNGs through `\fig{name}`. `scripts/build_figures.sh` builds the PDF, PNG and
  SVG for each; `book/figures/README.md` has the style rules and the index.
  Black lines, one light grey, one accent colour for what is untrusted or
  wrong, Latin Modern, nothing decorative. Every figure is referenced with
  `\Cref{fig:*}` and shows a mechanism the prose describes; a figure nobody
  refers to, or one that only decorates, is clutter. Rebuild the figures after
  editing a source; the book build only includes the PNGs.
- `\code{}` for literals, `\term{}` for a term being introduced.
- Cross-references with `cleveref`: `\Cref{ch:powers}`, `\Cref{tab:hardware}`.
- Citations: `\textcite{}` in running prose, `\parencite{}` parenthetically.
- Labels: chapters `ch:*`, tables `tab:*`, figures `fig:*`, appendices `app:*`
  (`app:glossary`, `app:checklists`, `app:tutorials`, `app:stateofplay`).
- Prices, exact model versions, harness lists and usage limits go in
  `A4-state-of-play.tex` (`app:stateofplay`), dated. Chapters keep the reasoning
  and the lasting names (Apple M-series unified memory, Qwen, Ollama, Claude
  Code) and point there for the rest.
- No Greek or other non-Latin characters in the `.tex` files — the build is
  `pdflatex` with T1 fonts and they fail. Transliterate.

## Build

No Makefile, deliberately. One command:

```bash
cd book && latexmk -pdf main.tex
```

Or by hand: `pdflatex` → `biber` → `pdflatex` → `pdflatex`.
Clean with `latexmk -C`.

The figures are built separately, and only when a source under
`book/figures/tikz/` changes:

```bash
scripts/build_figures.sh               # all; or name one figure
```

It needs `pdflatex`, `pdftoppm` and `pdftocairo`. `graphicx` is in the
preamble for this reason and no other.

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

Orphan check (every entry cited, every citation defined). Both lists must be empty:

```bash
cd book && python3 -c "
import re,glob
keys=re.findall(r'^@\w+\{([^,]+),',open('references.bib').read(),re.M)
tex=''.join(open(f).read() for f in glob.glob('chapters/*.tex'))
cited={k.strip() for g in re.findall(r'\\\\(?:text|paren)?cite\{([^}]*)\}',tex) for k in g.split(',')}
print(len(keys),'entries; uncited:',[k for k in keys if k not in cited],'undefined:',sorted(cited-set(keys)))"
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

## Decisions already made

Settled by the author. Don't reopen them in reviews or suggestions.

- **Keep the reusable style guide anonymous.** In `WRITING_STYLE.md`, refer to
  the source as "the author's writing sample". Do not include the author's name,
  the sample's identifying filename or personal details. Use it for paragraph
  structure, rhythm and flow only; do not import its claims or references.
- **Scope is biodiversity.** The title is *AI for Biodiversity: A Primer*. The
  subject is language models and agents applied to biodiversity data and
  literature; image, sound and species distribution models stay brief (Ch. 4).
- **The wider frame stays.** The last section of `12-security-and-biorisk.tex`
  (noosphere, evolvable
  AI, biospheric AI, von Neumann) is where data, complexity and history meet.
  It is core, not a tangent: strengthen and connect it, never propose cutting it.
- **KYBELE is the worked example** for biodiversity literature and knowledge
  retrieval, to be expanded (see Open work).
- **Details that will date go in Appendix D.** Lasting names stay in the
  chapters (see Formatting).
- **Deliberate exclusions from Appendix C:** Anna's Blog, the paper code
  repositories from `../literature/` (not general tools), and
  `simplifyingcomplexity.tech` (it couldn't be verified).
- **Ananiadou entry, `14-keeping-up.tex`:** "in the department where Turing worked" stays,
  by the author's decision of 10 October 2026, although no source in
  `../literature/` covers it. Don't flag it again.

## Open work

Chapter numbers changed on 11 October 2026, when two chapters were added:
"A First Agent Session" (`09b-first-agent-session.tex`, Chapter 10) and
"Testing a Model on Your Own Task" (`11b-testing.tex`, Chapter 13). Former
Chapters 10–14 are now 11, 12, 14, 15 and 16. Name chapters by file in this
file; completed rows below keep the numbers in use when they were written.

Pick from here. Items marked **author** need the author's decision or material
first: propose, don't implement.

| Item | Status | Who |
|---|---|---|
| The Turing Way reading recommendation | Completed 1 October 2026: official online book linked and described at the start of Appendix C | Agent |
| Linguistic revision and reusable author style guide | Completed 30 September 2026; see `WRITING_STYLE.md` and `LINGUISTIC_REVISION.md` | Agent |
| October literature additions and benchmarks | Completed 1 October 2026: consciousness in Ch. 1; five ecological and microbial studies in Ch. 4; data provenance in Ch. 5; Red Hat guidance and evaluation procedure in Ch. 10 and 12; Krakauer and Levin in Ch. 14; web readings in Appendix C. See `LITERATURE_UPDATE.md` for sources and checks | Agent |
| `openai2026huggingface` misattributed in Ch. 5 and `12-security-and-biorisk.tex` (see Bibliography) | Rewording prepared on 10 October in `PROPOSED_SOURCE_CORRECTION.patch`; not applied, awaiting author's decision | Agent proposes, **author** decides |
| Expand KYBELE as the running example | Blocked: KYBELE's design documents (repo, design doc, BEeS 2026 abstract, RIO draft) must be in `../literature/` first. `Kybele HCMR.md` covers tools only. Never write KYBELE features or results by inference | **author** |
| Where KYBELE lives | Undecided. Recommended: thread it through Ch. 5 (retrieval), 7 (its AGENTS.md), 9 (logging), local-first (as now), security (scope enforced in code), scientific workflow (literature stage); the first agent session could use KYBELE data once the design documents exist. A dedicated chapter would need a `NOTES.md` entry | **author** |
| Seth (2026), standalone article | Completed 10 October 2026: supplied combined PDF read; added with the Richards and Agüera y Arcas reply in Ch. 1 and cited in Ch. 14. Print year 2026; online publication 2025 recorded in the bibliography | Agent |
| Richards and Agüera y Arcas (2026), BBS commentary on Seth, doi:10.1017/S0140525X25103646 | Completed 10 October 2026: reply found on pp. 76–77 of the combined Seth PDF; added as a pair in Ch. 1 and cited in Agüera y Arcas's Ch. 14 entry | Agent |
| CME 295 (Stanford, Transformers & LLMs) in Appendix C | Completed 10 October 2026: unsectioned paragraph after The Turing Way. Whether to add a "Courses" section instead is offered, unanswered | Agent; section question **author** |
| ZS Associates, "The economics of expertise" (Medium, in `../literature/` since 1 October) | Completed 10 October 2026: read and placed in Appendix C as a perspective by Peter MacLean and Emily Shaw McLaughlin; no new blog bibliography entry | Agent |
| October 10 literature and link review | Completed: transformer paper added in Ch. 2 and glossary; Palermo commentary clarified; Stanford lectures and cheatsheet, NVIDIA's Fundamentals of Deep Learning course, Red Hat implementation example and ZS essay linked in Appendix C. NVIDIA's repository address and active status checked through GitHub's API. See `LITERATURE_REVIEW_2026-10-10.md` for checks and link limitations | Agent |
| Rename "Researchers" in Appendix C to "Researchers and research infrastructures" (the iDigBio webinar sits there) | Offered, unanswered | **author** |
| Trim the Bauer et al. sentence (security chapter, Governance); state that most measured evidence is biomedical, not ecological; guidance for R users; guidance for database maintainers (offering a database to agents via MCP) | Proposed in review, unanswered. The last two need sources in `../literature/` first | **author** |
| Literature gap review (Consensus Pro, 10 October 2026) | Completed: 43 open-access sources downloaded into `../literature/`, checked and cited across Chs. 2–5 and 7–14 (attribution fixes, data-ethics sources, ecological evidence, both sides where sources disagree). Ananiadou and Thessen now cited; Greek podcast example sourced (Paraskevopoulos et al.). See `LITERATURE_GAPS_2026-10-10.md`. Eight more added from PDFs the author supplied (Fox, Uryu, Khan, Hughes, Berger-Tal, Laignelot, Jennings, Tulloch). Still needed: Cui et al. 2026, *Management Science* (closed access), to pair with the METR trial in Ch. 7 | Agent; Cui PDF: **author** |
| Book review of 10 October 2026 (`BOOK_REVIEW_2026-10-10.md`): positioning against comparable work, writing, textbook use | Answered 11 October 2026 and done: testing chapter (`11b-testing.tex`, `ch:testing`, with an R exercise); hands-on harness tutorial modelled on CME 295 (`09b-first-agent-session.tex`, `ch:firstsession`); consciousness exchange moved to the wider frame; CC BY 4.0 on the title page; one-figure rule added to Prose. Workshop companion in R started in `workshop/` (session and testing, both tested locally; the hosted track was not run). Not yet done: applying the one-figure rule to Chs. 4, 11 and 14; labs on a retrieval assistant and on reproducibility. Still proposed, unanswered: learning outcomes, index and version; trimming Chapter 4's catalogue; sources on the EU AI Act, the Cali Fund, DOME/TRIPOD-LLM, ARETE and Cooper et al. 2024 | Agent; open items **author** |
| Workshop housekeeping | Agents don't delete. The author may remove `workshop/testing/key/RULES.md` (a duplicate of `workshop/testing/RULES.md`) and `workshop/testing/results/` (test outputs, kept in `workshop/answers/testing-run-2026-10-11/`), so that learners start with an empty results folder | **author** |
| Torresani et al. (2026), BioScience viewpoint on opening ecological data, doi:10.1093/biosci/biag147 (in `../literature/` since 14 October) | Completed 14 October 2026: cited twice in `05-ai-ready-data.tex`, beside the point that AI-ready data may return no credit to curators, and after Stanford HAI on closed training data making bias hard to audit | Agent |
| Wood-Charlson et al. (2026), Communications Biology perspective on FAIR + COPE, doi:10.1038/s42003-026-10694-y (in `../literature/` since 14 October) | Completed 14 October 2026: one paragraph in the Standards section of `05-ai-ready-data.tex`, after I-ADOPT and DataHarmonizer; COPE added to the glossary | Agent |
| Dearborn, "Who Will Steward Humanity's Public Data?" (talk, 10 September 2026; slides and transcript in `../literature/`) | Completed 14 October 2026: added to the Library Innovation Lab entry in Appendix C, linked to the blog post of 24 September that carries the transcript and recording (title from the page `<title>`); one pointer sentence in the Infrastructure section of `05-ai-ready-data.tex`. Not a bibliography entry | Agent |
| Figures for the book and the workshop slides | Completed 14 October 2026: 41 TikZ diagrams in `book/figures/`, two or three per chapter, built to PDF, PNG and SVG by `scripts/build_figures.sh`; each captioned, labelled `fig:*` and referenced in its chapter. Style and index in `book/figures/README.md`. The author decides whether any should go, and whether the book should include the PDFs instead of the PNGs (one line in the preamble) | Agent; review **author** |
| New files in `../literature/` | Check whenever you start: anything not in `references.bib` is a candidate. Read it in full before placing it | Agent |

When you finish an item, update this table and `book/README.md` (Open issues)
in the same change.

## Working with other agents

Several agents may work here, in different harnesses and sessions. None can see
another's private memory or chat. **This file and `book/README.md` are the
shared record**: a decision that exists only in your context is lost to
everyone else.

- **One file, one agent.** Split work by chapter. `references.bib`, `main.tex`,
  `AGENTS.md` and `book/README.md` are shared, so only one agent edits each at a
  time. If you are running in parallel, hand your bibliography entries to
  whoever owns `references.bib` rather than editing it yourself.
- **Verify, don't trust.** Re-run the checks on another agent's work before
  building on it: build, `verify_bib.py`, the orphan check, `check_language.py`,
  `check_plagiarism.py`. A report that says "all checks passed" without output
  is not evidence.
- **Keep the numbers true.** After a bibliography change, update the counts
  (entries, DOIs, arXiv IDs, checked by hand) here and in `book/README.md`.
  After adding a key point or table, update those counts in Formatting.
- **Report back** with:
  1. what changed, as a diff or a file-and-line list;
  2. each check, with its actual output;
  3. what you did not verify, and why;
  4. questions for the author, kept separate from what you did.
- **Delegating a task:** give the receiving agent the chapter or files, the
  source documents in `../literature/`, the checks to run, and the relevant
  lines from Decisions and Open work. Don't assume it has read this file.
- Harnesses read different files. Codex and OpenCode read `AGENTS.md`. Claude
  Code reads `AGENTS.md` when there is no `CLAUDE.md` in the working directory
  or above it (version 2.1.277 or later, per its documentation, checked
  11 October 2026); older versions read only `CLAUDE.md`. If an agent ignores
  these rules, ask the author whether to add a `CLAUDE.md` containing
  `@AGENTS.md`. Don't create one yourself.
