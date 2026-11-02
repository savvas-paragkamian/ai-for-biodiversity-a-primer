# AGENTS.md

Conventions for agents working in this repository. Written in response to things
that have actually gone wrong. Read before editing.

## What this is

A LaTeX textbook, `book/`, called *AI for Biodiversity: A Primer*. Source material
is the Markdown notes in this directory and the papers in `../literature/`.
Four Beamer decks for the HCMR workshop live in `presentations/`, built from
the book's text, figures and bibliography; `presentations/README.md` and
`presentations/BRIEF.md` say how they are made and revised.

`NOTES.md` is the outline the book follows. Treat it as the table of contents:
if you add a chapter, it should correspond to something there, and if you find
yourself wanting a section that isn't in `NOTES.md`, say so rather than
inventing one.

## Start here

Any agent, any harness. Read in this order before changing anything:

1. This file, all of it. Then **Independent reviews**, **Decisions already
   made** and **Open work** near the end, so you don't reopen settled
   questions or duplicate work.
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
- **Never commit.** The author commits. The one exception so far is the peer
  review of 17 October 2026: the author asked for it to be done in git, and
  each reviewer committed to its own `review/*` branch (see **Independent
  reviews**). `main` was not touched. Any other commit still needs the
  author's say-so.
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
minutes and there is no acceptable reason to skip it. There are 231 entries:
all 114 DOIs and all 69 arXiv IDs pass, with title, first author and year
compared (2 November 2026), and 48 entries have neither and were checked by
hand. Grant DOIs (CORDIS, `10.3030/...`) carry their title in
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

**Resolved, 22 October 2026 (author's decision D3):** `openai2026huggingface`
was cited in `05-ai-ready-data.tex` and `12-security-and-biorisk.tex` for model
files carrying executable payloads, which the OpenAI page does not discuss.
Both sentences now cite it only for what it reports: agents escaping an
evaluation sandbox through a package-cache proxy. The model-file warning was
dropped; it would need its own source in `../literature/`.

**Web pages as sources.** A web page with no PDF may be saved as HTML in
`../literature/`, with a hand-written `.bib` beside it giving the date it was
saved (first done for the Epoch AI data insight, 2 November 2026).

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
- Figures: 44 diagrams, two or three per chapter (none in the preface or the
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
  Sections get a `sec:*` label only when another chapter points to them; the
  first four, added in the revision of November 2026, are `sec:fitformodel`
  and `sec:abs` (Ch. 5), `sec:analysis` (Ch. 7) and `sec:outputasdata`
  (Ch. 9).
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

## Independent reviews

On 17 October 2026 three AI agents reviewed the whole book as referees for a
top-tier book series, each with an expert persona: an ecologist who uses R
(R1), a bioinformatician who uses AI (R2) and a systems microbiologist (R3).
All three recommend major revision. They are not human referees; read the
reviews as a pre-submission check.

- **Where they are.** Each reviewer has a branch: `review/R1-ecologist`,
  `review/R2-bioinformatician` and `review/R3-systems-microbiologist`. Each
  holds `reviews/<reviewer>/report.md`, an index
  `reviews/<reviewer>/comments.tsv` (id, file, line, severity, chapter,
  summary) and the chapters with inline comments. `review/combined` merges
  all three: 290 comments (R1 83, R2 131, R3 76), 57 of them major. The
  `line` column is where the comment sits on that reviewer's branch, not in
  `main`. A synthesis with the shared concerns and a 13-item revision
  checklist is a private Claude Docs page:
  <https://claude.ai/artifact/YGQqBLBUdjG2ZpWn3FUbgC>.
- **Comment format.** LaTeX comment lines directly above the line concerned:
  `%% [R1-ECO-014 | major] text`, continued as `%%   text`. Severities are
  major, minor, factual, citation, clarity and typo. The PDF is unchanged:
  119 pages, with the same text as `main`.
- **Reading them.** `git diff main review/combined -- book/chapters/<file>`
  shows one chapter's comments in place. Don't merge a `review/*` branch into
  `main`, and don't copy the `%%` lines into the source.
- **Chapter numbers.** The reviewers used the numbers in the PDF: Ch. 6 is
  `06-organisation-and-backup.tex`, 10 `09b-first-agent-session.tex`, 11
  `09c-weekly-literature.tex`, 12 `10-local-first.tex`, 13
  `11-hardware.tex`, 14 `11b-testing.tex`, 15 `12-security-and-biorisk.tex`,
  16 `13-scientific-workflow.tex` and 17 `14-keeping-up.tex`.
- **Comments are proposals, not instructions.** The reviewers did not see
  this file, so they did not know the decisions below. Where a comment
  contradicts **Decisions already made**, the decision stands and the comment
  goes to the author. Two do. All three reviewers propose moving the wider
  frame to an epilogue, and R1 would also halve it. R1 and R3 offer adding
  image, sound, SDM and molecular material as one way to settle the scope.
- **How it was done**, to repeat it. One git worktree and branch per
  reviewer, outside the project folder. A non-cone sparse checkout held only
  `.gitignore`, `book/`, `scripts/`, `workshop/` and `reviews/`, so the
  reviewers never saw this file, `WRITING_STYLE.md`, `NOTES.md` or the
  earlier review and revision files. Each was a fresh agent with no shared
  context, told not to read outside its worktree or look at other branches.
  Comments were insertions only.
- **Checks that passed** on every branch: no deleted lines; every added line
  in a `.tex` file starts with `%%`; the TSV rows match the inline IDs; the
  PDF text matches `main`'s. A plain `git merge` of the three branches
  conflicts in 18 chapter files, because reviewers commented above the same
  lines. `review/combined` was built instead by keeping every reviewer's
  insertions at each position, in R1, R2, R3 order. Removing the other
  reviewers' comments from it recovers each branch exactly. Its commit has
  four parents: `main`, R1, R2 and R3.
- **Limits.** All three agents ran on the same underlying model, so they may
  share blind spots. `book/README.md` was visible to them and already flags
  `openai2026huggingface`, so their agreement on it is partly prompted.
- The sparse checkouts set `extensions.worktreeConfig = true` in
  `.git/config`. It is harmless; the author may remove it with
  `git config --unset extensions.worktreeConfig`. The worktrees were removed;
  the branches remain.

## Decisions already made

Settled by the author. Don't reopen them in reviews or suggestions.

- **Keep the reusable style guide anonymous.** In `WRITING_STYLE.md`, refer to
  the source as "the author's writing sample". Do not include the author's name,
  the sample's identifying filename or personal details. Use it for paragraph
  structure, rhythm and flow only; do not import its claims or references.
- **Scope is biodiversity.** The title is *AI for Biodiversity: A Primer*. The
  subject is language models and agents applied to biodiversity data and
  literature; image, sound and species distribution models stay brief (Ch. 4).
- **The wider frame stays.** Noosphere, evolvable AI, biospheric AI, von
  Neumann and the consciousness exchange: where data, complexity and history
  meet. It is core, not a tangent: strengthen and connect it, never propose
  cutting it. By the author's decision of 22 October 2026 (D2) it moved,
  unchanged in length, from the end of `12-security-and-biorisk.tex` to its
  own chapter after Keeping Up: `14b-epilogue.tex`, "Epilogue: The Wider
  Frame", `ch:epilogue`.
- **Declared interests (D4, 2 November 2026).** `venetsianou2026relatedness`
  is co-authored by the author. It is cited only in Chapter 4, with the
  disclosure there. KYBELE is the author's project and is presented as a
  design ("KYBELE: a design", D5) until its design documents are in
  `../literature/`.
- **No CI, no DOI, no hosted run (D11, 2 November 2026).** The workshop gets
  no CI job or Zenodo DOI, the hosted track of Chapter 10 is not run, and
  nothing is tested on Windows. Untested parts are labelled as untested.
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
Chapters 10–14 are now 11, 12, 14, 15 and 16. They changed again on
14 October 2026, when "A Weekly Literature Review"
(`09c-weekly-literature.tex`) became Chapter 11 and the former Chapters 11–16
became 12–17. Name chapters by file in this file; completed rows below keep
the numbers in use when they were written.

Pick from here. Items marked **author** need the author's decision or material
first: propose, don't implement.

| Item | Status | Who |
|---|---|---|
| The Turing Way reading recommendation | Completed 1 October 2026: official online book linked and described at the start of Appendix C | Agent |
| Linguistic revision and reusable author style guide | Completed 30 September 2026; see `WRITING_STYLE.md` and `LINGUISTIC_REVISION.md` | Agent |
| October literature additions and benchmarks | Completed 1 October 2026: consciousness in Ch. 1; five ecological and microbial studies in Ch. 4; data provenance in Ch. 5; Red Hat guidance and evaluation procedure in Ch. 10 and 12; Krakauer and Levin in Ch. 14; web readings in Appendix C. See `LITERATURE_UPDATE.md` for sources and checks | Agent |
| `openai2026huggingface` misattributed in Ch. 5 and `12-security-and-biorisk.tex` (see Bibliography) | Completed: the author approved the rewording (D3, 22 October 2026) and it was applied in both chapters | Agent |
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
| A weekly literature review: Chapter 11 (`09c-weekly-literature.tex`, `ch:weeklyliterature`) and the `weekly-literature` repository | Completed 14 October 2026: chapter with seven prompts and three figures (`ch11-two-layers`, `ch11-week-pipeline`, `ch11-citation-check`), glossary "Skill", Appendix C entry, dated versions section in Appendix D, `workshop/literature/` with the fixture week and a frozen live week. The repository lives at `~/projects/weekly-literature` (outside Dropbox; `git init` done, nothing committed, not on GitHub). No new bibliography entries. The former ch11–ch16 figure files were renamed to ch12–ch17 by `scripts/renumber_figures.sh` on the author's instruction the same day. **Author decides:** `gh repo create savvas-paragkamian/weekly-literature --public`, first commit and push, then check the Appendix C name against the GitHub API; add the `NOTES.md` entry proposed in the agent's report; licence (MIT code, CC BY 4.0 reviews suggested); a key point ("a reference enters a bibliography through a script that resolved it, never through a model") only if one of the twelve goes; commit `workshop/`. The skill's live run (needs the Consensus login) was not performed | Agent; decisions **author** |
| Peer review by three AI reviewers, 17 October 2026 (see **Independent reviews**) | Completed: three reports and 290 inline comments on the `review/*` branches, all recommending major revision; nothing in the book was changed. Raised by all three: a claim-level citation audit (`openai2026huggingface` and others); author parsing in the Chapter 11 pipeline, and `verify_bib.py` checking titles but not authors or years; statistics and controls in `11b-testing.tex`; the security chapter (injection versus jailbreaking, sandboxes, sensitive species localities); undeclared interests (Venetsianou et al., KYBELE, PromptBio-Bench). Listings that fail as printed (R1, R2): the checksum recipe in `06-organisation-and-backup.tex` and the Dockerfile in `09-reproducibility.tex`. **Author decides** which of the synthesis's 13 checklist items to accept; agents then work one chapter at a time. Triage and plan of 22 October 2026: `REVISION_PLAN_2026-10-22.md` (14 author decisions, 12 work packages, sources to obtain) and `REVIEW_TRIAGE_2026-10-22.tsv` (every comment with a disposition, work package and status column; 193 need no decision or new source, 27 need a source first, 59 need the author) | Agent reviewed; **author** decides |
| Revision answering the peer review | Completed 2 November 2026, one agent per chapter, after the author's answers to D1–D14 (`REVISION_PLAN_2026-10-22.md`) and of 2 November (D4, D11; `REVISION_PLAN_2026-11-02.md`). All 290 comments have a status in `REVIEW_TRIAGE_2026-10-22.tsv`: 269 done, 13 declined under the author's decisions, 8 for the author. Every citation has a row with its supporting passage in `CLAIM_AUDIT_2026-10/`. Testing exercise rerun on 2 November (`workshop/answers/testing-run-2026-11-02/`). Not done: the second review (plan, section 7); figure `ch01-agent-loop` does not yet show the turn budget the Ch. 1 listing has | Agent |
| Open questions from the revision of 2 November 2026 | (1) `workshop/testing/RULES.md` still ends with the superseded rules of 11 October, and `02_extract.R` sends the whole file to the model, so the 2 November runs saw both; moving them out needs a rerun, and `qwen3:8b` is no longer installed. (2) Sources to supply: Sica et al. 2025 (Humboldt Extension) and Rhinehart et al. 2022 (both open access on Wiley, which blocks scripts); Phillips 2009, Isaac 2020, Yates 2018 (to name the SDM bias remedies in Ch. 4); the PDFs of `gill2023dataharmonizer` and `saezrodriguez2026benchmarking` (only citation files are in `../literature/`). (3) People list (D12): the recount added people found only by expanding "and others" author lists; decide whether that counts, and pick from the shortlist of women in the agent's report (gender was inferred from names, so check). (4) Karpathy named for "vibe coding" from the author's notes only; Yegge for CHOP needs a document. (5) Licence of the abstract excerpts redistributed in `workshop/literature/data/raw/` (findings in the plan). (6) Chapter 11 is 3.6% shorter, not 10%; printing prompts 4 and 5 as summaries would reach it. (7) Renames offered, not done: `ch10-three-layers` and `ch15-shared-layer` no longer describe their figures | **author** |
| Literature check of 2 November 2026, evening | Completed. The DRAM column (`krakauer2026dram`) and the species-interaction workflow (`keck2026interactions`) were already cited by the day's revision; Ch. 4 now gives the workflow's four stages, Ch. 2 adds Krakauer's remedy (keep machines in service longer) and his Ch. 17 entry cites the column. Three sources never considered before were added: Stahlman and Kouper (long-tail data; Chs. 5 and 6, glossary), Gadelha et al. (survey of biodiversity informatics; Chs. 5 and 6) and Ranjan, Potter and Palmer (cyberbiosecurity; Ch. 15, glossary; the DOI comes from the publisher's record saved beside the PDF). Left out: the *Cell* biomedical set (out of scope, per the triage of 2 November), Guo, Liu and Gore on superposition (no argument in the book needs it), Kleppmann's local-first meetup slides (no venue or URL), the author's own unpublished abstract *Knowledge Preservation in biodiversity* (not a source), and the two `citations-*.bibtex` files (citation records, not documents). Claim-audit rows added and line numbers shifted for the seven edited files | Agent |
| Workshop slides, `presentations/` | Completed 2 November 2026: four Beamer decks of 34 pages each, one agent per deck from a shared brief (`presentations/BRIEF.md`) and a shared preamble (`presentations/common/preamble.tex`, Latin Modern, black on white, the book's figures from `book/figures/png/`, `references.bib` as the only bibliography). Deck 1 Parts I–II, deck 2 Parts III–IV, deck 3 the three exercises with `workshop/`, deck 4 Part V and the appendices. Fifteen cited papers appear as a screenshot of their first page (`presentations/common/screenshots/`). Every deck builds with zero errors and no biber warnings; 64 distinct keys cited, all in `references.bib`. Each deck's agent listed what it left out for the 34-page budget; the author reviews the slides as they review the book. The figure `ch03-guessing-wins` had an overlapping label, found while making deck 1 and fixed in its TikZ source the same day | Agent; review **author** |
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
