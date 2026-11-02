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
knowledge retrieval (Chapter 12, "KYBELE: a design"). It is being expanded; at
the time of writing its serving layer runs, its orchestrator is designed but
not built, and its tests are planned, not run.

## Contents

About 40,000 words, 149 pages (2 November 2026).

| Part | Chapters |
|---|---|
| Preface | Audience, the three arguments, how the book was written |
| I. The Landscape | 1 Chatbots, Models and Agents · 2 Why Now? · 3 Powers and Limitations · 4 Applications in Biology and Ecology |
| II. Data | 5 AI-Ready Data · 6 Organising and Protecting Your Data |
| III. Working with Agents | 7 The Agentic Coding Workflow · 8 The Software Stack · 9 Reproducibility When the Tool Varies · 10 A First Agent Session (hands-on, in R, with `../workshop/session`) · 11 A Weekly Literature Review (hands-on, in R, with `../workshop/literature`) |
| IV. Local-First | 12 The Local-First Approach (with the KYBELE example) · 13 Hardware for Local Inference · 14 Testing a Model on Your Own Task (with an R exercise, `../workshop/testing`) |
| V. Risk, Integrity and Keeping Up | 15 Security, Biorisk and Governance · 16 Changes Across the Scientific Workflow · 17 How to Keep Up · 18 Epilogue: The Wider Frame (noosphere, evolvable AI, the inherited archive, consciousness) |
| Appendices | A Glossary · B Checklists · C Tutorials (videos, newsletters, blogs, awesome lists, tool repositories) · D State of Play, September to October 2026 (prices, model versions, harnesses, usage limits) |

If you read one chapter, read Chapter 3.

The chapters are written to last; names, prices and limits that will date live
in Appendix D, and links that will rot live in Appendix C.

Four Beamer decks for teaching the book are in `../presentations/`, built
from these chapters, the figures and the bibliography (see its README).

## Licence

Creative Commons Attribution 4.0 International (CC BY 4.0), stated on the
title page. The workshop companion in `../workshop/` carries the same licence.

## Build

Needs TeX Live with `pdflatex` and `biber`.

```bash
latexmk -pdf main.tex        # build
latexmk -pdf -pvc main.tex   # rebuild on save
latexmk -C                   # clean, including the PDF
```

By hand, if you prefer: `pdflatex` -> `biber main` -> `pdflatex` -> `pdflatex`.

The figures are included as PNGs from `figures/png/` and are rebuilt only when
a TikZ source changes: `scripts/build_figures.sh` from the repository root
(needs `pdflatex`, `pdftoppm`, `pdftocairo`). To include the vector PDFs
instead, change `\DeclareGraphicsExtensions{.png}` in `preamble.tex` to
`.pdf` and `\graphicspath` to `figures/pdf/`.

## Layout

```
main.tex          parts and chapter includes
preamble.tex      packages, formatting, biblatex setup
references.bib    231 entries, grouped by theme
figures/          44 diagrams: style.tex, tikz/ sources, pdf/ png/ svg/ outputs,
                  README.md with the style rules and an index
chapters/
  00-preface
  01-landscape  02-why-now  03-powers-and-limits  04-applications
  05-ai-ready-data  06-organisation-and-backup
  07-agentic-workflow  08-software-stack  09-reproducibility
  09b-first-agent-session  09c-weekly-literature
  10-local-first  11-hardware  11b-testing
  12-security-and-biorisk  13-scientific-workflow  14-keeping-up  14b-epilogue
  A1-glossary  A2-checklists  A3-tutorials  A4-state-of-play
```

## Bibliography

Assembled from the `.bib`, `.ris` and `.bibtex` files in `../../literature/`,
plus entries taken from the PDFs there.

Verified on 2 November 2026: all 114 DOIs resolve through Crossref (or
DataCite) and all 69 arXiv IDs through the arXiv API, with title, first author
and year matching in every case. The remaining 48 entries are reports, books,
blog posts and web pages with no such identifier, checked by hand. Every entry
is cited at least once, and every citation has a row in the claim audit
(`../CLAIM_AUDIT_2026-10/`) giving the passage that supports it.

Videos, newsletters, blogs and code repositories are not bibliography entries;
they are listed in Appendix C, with names checked against YouTube, GitHub and
the publishers' own sites.

## Checks

Run from the repository root. Each has a `--self-test` that plants errors and
confirms they are caught. Needs `pandoc`, `pdftotext` and `hunspell`.

```bash
python3 scripts/verify_bib.py          # every DOI and arXiv ID resolves; title, first author and year match
python3 scripts/check_plagiarism.py    # 8-word verbatim overlap with ../literature
python3 scripts/check_language.py      # British spelling, banned words, long sentences
```

The last two produce lists to read, not verdicts: names, numbers and your own
notes will match.

## Open issues

The Turing Way was added to Appendix C on 1 October 2026 as an online reading
recommendation, with its title, community authorship and scope checked against
the official book site. Stanford's CME 295, *Transformers & Large Language
Models* (Afshine and Shervine Amidi), was added beside it on 10 October 2026,
with its title and instructors taken from the course site.

The linguistic revision was completed on 30 September 2026. See
[`LINGUISTIC_REVISION.md`](../LINGUISTIC_REVISION.md) for changes and checks.
The author's thesis informed paragraph structure and flow only; it was not
used as a factual source.

The literature update of 1 October 2026 adds consciousness, Red Hat deployment
guidance, ecological extraction, plant traits, microbial phenotypes and
microbiome study comparisons. Chapter 10 now gives a practical benchmarking
procedure, and Chapter 14 includes David C. Krakauer and Michael Levin.
See [`LITERATURE_UPDATE.md`](../LITERATURE_UPDATE.md) for the source map,
verification results and remaining limits.

The review of 10 October 2026 adds Vaswani et al.'s transformer paper and the
Seth–Richards/Agüera y Arcas consciousness exchange. Chapter 2 distinguishes
parallel training from sequential text generation and qualifies Palermo's
biotech acquisition forecast. Appendix C now guides readers through the first
three Stanford lectures and links the cheatsheet, the ZS expertise essay and
Red Hat's multimodal implementation example. NVIDIA's Fundamentals of Deep
Learning course precedes Stanford as a practical introduction using PyTorch
notebooks; its current repository address and active status were checked.
The Simplifying AI address is
updated, and the complete Stanford HAI open-weight article link appears there.
See [`LITERATURE_REVIEW_2026-10-10.md`](../LITERATURE_REVIEW_2026-10-10.md)
for the task-only diff, checks and remaining link limitations.

- `openai2026huggingface` was cited in Chapters 5 and 15 for model files
  carrying executable payloads, which the source does not discuss. Resolved:
  the author approved the rewording in
  [`PROPOSED_SOURCE_CORRECTION.patch`](../PROPOSED_SOURCE_CORRECTION.patch)
  (D3, 22 October 2026), and both sentences now cite it for the sandbox escape
  it reports.
- KYBELE's expansion as the running example needs its design documents in
  `../../literature/` before it can be written up.
- The combined Seth PDF supplied on 10 October contains both his target
  article and the Richards/Agüera y Arcas reply (pp. 76–77). Both are now
  cited together in the wider frame of Chapter 14 and in the people list in
  Chapter 16; Chapter 1 keeps one paragraph separating intelligence from
  experience.
- The ZS Associates essay is now in Appendix C, with its authors named and
  its argument distinguished from evidence of skill loss in ecology.
- The literature gap review of 10 October 2026,
  [`LITERATURE_GAPS_2026-10-10.md`](../LITERATURE_GAPS_2026-10-10.md),
  added 43 sources: attributions for sentences that had none, FAIR, CARE and
  the Disentis Roadmap in Chapter 5, ecological evidence in Chapters 4 and 11,
  and both sides where sources disagree. Ananiadou and Thessen are now cited
  in Chapter 16, and the Greek podcast example in Chapter 8 has its source.
  Eight further sources were added from PDFs the author supplied; one, Cui et
  al. (2026), is still awaited and is not cited.
- A review of the book's positioning, writing and use as a textbook,
  [`BOOK_REVIEW_2026-10-10.md`](../BOOK_REVIEW_2026-10-10.md), compares it with
  comparable articles, books, guides and courses. On 11 October 2026 the
  author accepted five proposals, now done: a testing chapter (13, moved from
  the local-first chapter, with an R exercise); a hands-on agent session
  (Chapter 10, modelled on Stanford's CME 295); the consciousness exchange
  moved to the wider frame; CC BY 4.0; and a one-figure-per-study rule in
  `AGENTS.md`, not yet applied to existing chapters. Both exercises were run
  locally with Ollama on an Apple M1 Max laptop, and the chapters report what
  happened, failures included. The hosted track of Chapter 10 was not run.
  Learning outcomes, an index, figures and further sources remain proposals.
- Torresani et al. (2026), a BioScience viewpoint on opening ecological data,
  was added on 14 October 2026. Chapter 5 cites it where it makes the same
  points as the chapter: AI-ready data may return no credit to its curators,
  and closed training data make under-represented regions and taxa hard to see.
- Wood-Charlson et al. (2026), a Communications Biology perspective on
  FAIR + COPE, was added the same day: one paragraph in Chapter 5's Standards
  section on why FAIR data still needs harmonising and updating before it can
  be modelled, with COPE defined in the glossary.
- Jacqueline J. Dearborn's talk "Who Will Steward Humanity's Public Data?"
  (Library Innovation Lab, 10 September 2026) is in Appendix C under the Lab's
  blog, linked to the post that carries the transcript and recording, with a
  pointer from Chapter 5's Infrastructure section. Talks are web material,
  not bibliography entries.
- Figures were added on 14 October 2026: 41 TikZ diagrams, two or three per
  chapter, each captioned and referenced in the prose, with SVG versions for
  the workshop slides. See `figures/README.md`. Reviewed by the author on
  22 October 2026.
- Two existing bibliography links could not be verified in the October 10
  audit: the Financial Times returned access errors, and the saved Anna's
  Archive address failed certificate validation. Neither was replaced with
  a guessed address.
- Chapter 11, "A Weekly Literature Review" (`09c-weekly-literature.tex`), was
  added on 14 October 2026 as the second hands-on chapter: R scripts that
  fetch five sources by ISO week, merge, resolve every identifier and write
  Markdown, BibTeX and a provenance log, run by GitHub Actions; and a Claude
  Code skill in KYBELE's shape for notes that a model writes under a label.
  Seven prompts, three figures, a fixture week and one live week
  (`../workshop/literature`). The former Chapters 11–16 are now 12–17; chapter
  numbers in the bullets above are those in use when they were written. The
  figure files of those chapters were renamed to match
  (`scripts/renumber_figures.sh`, run on the author's instruction). The
  repository the chapter describes is
  public at <https://github.com/savvas-paragkamian/weekly-literature>; the
  skill's live run was not performed. Reviewed by the author on
  22 October 2026.
- On 17 October 2026 three AI agents reviewed the book as referees, with the
  personas of an ecologist, a bioinformatician and a systems microbiologist.
  All three recommend major revision. Their reports and 290 inline comments
  are on the `review/*` branches; the book itself was not changed. The
  author decides which revisions to accept. See Independent reviews in
  `../AGENTS.md`.
- The revision answering that review was carried out on 2 November 2026,
  one agent per chapter, after the author's answers to fourteen decisions
  (`../REVISION_PLAN_2026-10-22.md`, `../REVISION_PLAN_2026-11-02.md`). The
  status of every comment is in `../REVIEW_TRIAGE_2026-10-22.tsv`, and a
  claim audit with the supporting passage for every citation is in
  `../CLAIM_AUDIT_2026-10/`. Main changes: a scope paragraph and subtitle;
  training stages, scaling and mixture-of-experts in Part I; four new
  sections (`sec:abs`, `sec:fitformodel`, `sec:analysis`,
  `sec:outputasdata`); the security chapter rewritten (injection versus
  jailbreaking, sandboxes, sequence models, sensitive localities); the
  wider frame moved to an epilogue (Chapter 18); KYBELE presented as a
  design; the co-authored microbiome study cited only in Chapter 4, with
  the disclosure; the testing exercise rebuilt with nine fields and a
  held-out set, and rerun; listings fixed and tested (checksums, Dockerfile,
  DOI script, straight quotes in copied code).
- A literature check the same evening found Krakauer's column on the memory
  shortage and Keck et al.'s species-interaction workflow already cited by that
  revision. Chapter 4 now describes the workflow's four stages (scripts on both
  sides of the model), Chapter 2 adds Krakauer's remedy, and his entry in
  Chapter 17 cites the column. Three sources not considered before were added:
  Stahlman and Kouper on long-tail data (Chapters 5 and 6, glossary), Gadelha
  et al.'s survey of biodiversity informatics (Chapters 5 and 6) and Ranjan,
  Potter and Palmer's map of the cyberbiosecurity literature (Chapter 15,
  glossary). The biomedical *Cell* papers stay out, as the triage of 2 November
  recommended.
- Workshop slides were added on 2 November 2026 in `../presentations/`: four
  Beamer decks of 34 pages, one per pair of parts plus one for the exercises,
  in the style of Stanford's CME 295 lectures, using the book's figures and
  fifteen papers' first pages. Figure `ch03-guessing-wins` had an overlapping
  label and was fixed in its TikZ source. A setup deck (installation, Git basics, harness
  controls) and `../workshop/SETUP.md` were added the same evening; their
  commands come from the tools' documentation, dated, not from the book.

## Conventions

See `../AGENTS.md`. Briefly: minimal formatting, plain words over jargon, at most
one `keypoint` box per chapter, no table that restates the prose beside it, and
no citation to anything not sitting in `../../literature/`.

Read [`WRITING_STYLE.md`](../WRITING_STYLE.md) before drafting or revising prose.
It is the author's reusable guide to paragraph structure, rhythm and tone.
Keep the guide anonymous: refer to "the author's writing sample" and omit
personal names and identifying filenames, as recorded in `../AGENTS.md`.
