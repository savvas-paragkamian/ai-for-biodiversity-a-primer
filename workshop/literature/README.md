# Workshop: a weekly literature review (Chapter 11)

The hands-on material for Chapter 11 of *AI for Biodiversity: A Primer*,
"A Weekly Literature Review" (`book/chapters/09c-weekly-literature.tex`). It
is a copy of the author's `weekly-literature` repository reduced to two
topics, with two weeks of data that run offline, so that the counts printed
in the chapter can be reproduced on any machine without an API call.

**The week `2026-W00` is invented** (six fixture records across four sources;
one abstract contains an instruction aimed at AI assistants). **The week
`2026-W41` is real** (5 to 11 October 2026 plus ten overlap days, fetched on
14 October 2026), but reduced to the two topics and with every abstract cut
to forty words and marked as cut; the full responses are not distributed.
Do not cite anything from these files without opening the paper.

## Layout

```
config/interests.yml     two topics: Collembola, and coastal soil metagenomes
R/                       the scripts of the chapter (00_common to 04_write,
                         run_week, skill_verify, freeze_week)
tests/                   check_notes.R, recall.R, gold.csv, pushback.md, results.csv
docs/assistant-rules.md  the eight rules of the assistant skill
.claude/                 the skill and the permission settings
data/raw/2026-W00/       the fixture week
data/raw/2026-W41/       the frozen live week (FROZEN.md says what was cut)
provenance/agent-prompts.md   the seven prompts
answers/literature-run-2026-W41/   what the scripts produced when this was
                         prepared: review, bib, log, checked table, seen.csv
renv.lock                the package versions used
```

## What you need

R 4.5 with `httr2`, `jsonlite`, `yaml` and `xml2`
(`install.packages(c("httr2", "jsonlite", "yaml", "xml2"))`, or
`renv::restore()` for the exact versions). Biber, if you want to validate
the `.bib` files. No network for the two offline runs; the network for the
verifier's self-test and for a live week.

## Exercise

Copy this folder outside the book's repository and run, from inside the copy:

```bash
Rscript R/03_check.R --self-test          # needs the network; must print SELF-TEST PASSED
Rscript R/run_week.R 2026-W00 --offline   # the fixture week
Rscript R/run_week.R 2026-W41 --offline   # the frozen week, two topics
Rscript tests/check_notes.R --self-test   # the grounding check can fail
```

Then open `reviews/2026-W41.md`, `bib/2026-W41.bib` and
`provenance/2026-W41.log.md`, and compare with `answers/`. Running a week a
second time must change nothing in `bib/all.bib` and `data/seen.csv`.

## Expected results

The fixture week prints:

```
6 records read; 7 kept (0 bioRxiv records matched no topic); 4 after the DOI merge; 4 after the arXiv-identifier merge; 3 after the title merge
3 DOIs and 0 arXiv identifiers checked from the cached answers; 2 verified, 1 not
3 items in; 2 new; 0 now published; 0 updated preprints; 0 seen before; 1 not verified; 2 bibliography entries written
```

The one record that fails is the pair merged by title whose DOI resolves to
a different paper. The abstract that instructs assistants is listed like any
other; it is data.

The frozen week prints:

```
bioRxiv: 1331 records in the fetched categories; 5 matched a topic's terms (5 topic assignments); 1326 set aside
1357 records read; 31 kept (1326 bioRxiv records matched no topic); 25 after the DOI merge; 25 after the arXiv-identifier merge; 25 after the title merge
24 DOIs and 0 arXiv identifiers checked from the cached answers; 23 verified, 2 not
25 items in; 23 new; 0 now published; 0 updated preprints; 0 seen before; 2 not verified; 23 bibliography entries written
```

Twelve items fall under Collembola and eleven under coastal soil
metagenomes. The two unverified items are a journal article whose DOI
resolved at neither Crossref nor DataCite on 14 October and a university
repository record; the review lists both with the reason. The 1,326
bioRxiv records that matched neither topic show what the terms do: the
fetch returns whole categories, the vocabulary decides.

The assistant skill (`/weekly-literature 2026-W41` in Claude Code) needs a
Consensus login and was not run when this material was prepared; the
pushback test in `tests/pushback.md` and the grounding check are ready for
your run. Record each run in `tests/results.csv`.

## A live week

Put your own address in `config/interests.yml` (`contact`), add or edit
topics, and run `Rscript R/run_week.R` for the week that ended yesterday.
The counts will differ from the frozen week: indexes change, and the
ten-day overlap means the first run of a new week fetches seventeen days.
OpenAlex meters requests without an API key against a free daily budget
shared by every machine behind your address (observed 14 October 2026); one
run a day fits, a classroom behind one address may not. With a key, set
`OPENALEX_API_KEY` in the environment; the scripts never print it. A source
that was refused is recorded as failed and the week goes on without it.
