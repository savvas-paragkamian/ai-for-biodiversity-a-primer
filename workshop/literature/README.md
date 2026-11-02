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
.github/workflows/weekly.yml  the GitHub Actions clock (see Scheduling files)
launchd/                 the Mac clock, a launchd property list
docs/scheduling.md       the three ways to run the week on a clock
answers/literature-run-2026-W41/   what the scripts produced: review, bib,
                         log, checked table, seen.csv, the two run transcripts
                         (regenerated on 22 October 2026 after the author-name
                         fix described below)
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
Rscript R/02_normalise.R --self-test      # author names from every source parse to "Surname, Given"
Rscript R/run_week.R 2026-W00 --offline   # the fixture week
Rscript R/run_week.R 2026-W41 --offline   # the frozen week, two topics
Rscript tests/check_notes.R --self-test   # the grounding check can fail
Rscript tests/recall.R                    # the gold set against data/seen.csv
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
a different paper: its reason names both the title and the first author that
differ. The abstract that instructs assistants is listed like any other; it
is data.

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
fetch returns whole categories, the vocabulary decides. Each `ok` line of the
check now ends with `first author matches (...)`; see the next two sections.

## What the verifier checks

`R/03_check.R` resolves every DOI on Crossref, then on DataCite, and every
arXiv identifier on the arXiv API, and compares three things with our
record: the title (similarity at least 0.85, or one title is the other
without its subtitle), the first author's surname (lowercase ASCII; one may
contain the other, so "Gomes da Silva" and "Silva" agree) and the year (more
than one apart fails; one apart, online against print, is noted). A record
whose registrar entry names no author, or whose author is in a script that
cannot be transliterated, is verified by title and says so in its reason.
The reason is written into `data/normalised/<week>-checked.csv` and into the
review for anything that fails. Until 22 October 2026 the check compared
titles only.

The cached answers in `data/raw/2026-W41/crossref.json` were saved on
14 October 2026 with status and title. On 22 October a `first_author` and a
`year` field were added to the 23 answers the two-topic week uses, by one
live lookup each; status and title were not touched, so the offline run
reproduces the 14 October verdicts and also exercises the author check. A
cached answer without those fields makes the reason say `author not in the
cached answer` and the item is verified by title, as before.

`Rscript R/03_check.R --self-test` plants four failures and two good
identifiers: a DOI that does not exist, a real DOI with a wrong title, a
real DOI with a wrong first author (`10.1145/3644815.3644945`, whose first
author is Barnett; the planted "Kurniawan" is the error the book's own
bibliography carried until this revision, and a title-only check cannot see
it), an arXiv identifier that does not exist, and the two good ones.

## The author-name bug, as a worked example

Biodiversity PMC writes authors surname first, as in MEDLINE ("Blaya Romane",
"Du Ronghua"). Until 19 October 2026 the scripts passed those names to a
function that expects "Given Surname", so the frozen week's bibliography
read `author = {Romane, Blaya and Léo, Rocher ...}` with the key
`romane2026inter`, and the merge kept that string because it was the longest.
The verifier passed every one of them: it compared titles, and the titles
were right. Two of the book's three reviewers found it by reading the `.bib`
file; the third asked for the first-author comparison. Nine of the 23 entries of week 2026-W41 were affected; the keys that
changed are `xiuwen2026genotype` to `zhou2026genotype`, `jie2026metabolic`
to `wang2026metabolic`, `romane2026inter` to `blaya2026inter`,
`ronghua2026ecotoxicity` to `du2026ecotoxicity`, `juliane2026thiamethoxam`
to `gomesdasilva2026thiamethoxam` and `min2026evolutionary` to
`wang2026evolutionary`; three more entries kept their key and had their
co-authors' names put right.

What changed: every source's authors are now parsed from the fields that
source gives (Europe PMC `authorList` with `lastName` and `firstName`,
OpenAlex and arXiv names written given name first, bioRxiv "Surname, G.",
Biodiversity PMC surname first with its particles kept), each record carries
an `author_quality` (structured, given-first or initials), the merge keeps
the best-ranked string rather than the longest and records which source it
came from in the `authors_source` column, and the verifier compares the
first author's surname with the registrar's. `Rscript R/02_normalise.R
--self-test` parses a planted record from each source and checks that the
structured names win a disagreement. The lesson is the chapter's: a check
that cannot fail on the error you are worried about is not a check of that
error.

## Permissions

The skill's `allowed-tools` line pre-approves the tools it names for the
turn that invokes the skill; the Claude Code documentation says it "does not
restrict which tools are available: every tool remains callable"
(<https://code.claude.com/docs/en/skills>, read 22 October 2026). What keeps
the assistant out of files it must not change is the deny list in
`.claude/settings.json`: `Edit(...)` rules for `data/`, `bib/`, `reviews/`,
`config/`, `R/`, `tests/`, `docs/`, `.claude/`, `.github/`, `launchd/`,
the run logs and `renv.lock`, `Bash` rules for `curl`, `wget`, `git
commit` and `git push`, and a rule denying `WebFetch`. The documentation states that deny rules are
evaluated before ask and allow rules and that an allow rule cannot carve an
exception out of a deny rule (<https://code.claude.com/docs/en/permissions>),
and that `Edit(path)` rules cover every built-in tool that edits files.
Until 22 October 2026 the list left `tests/` and `docs/` writable, so the
assistant could have edited its own grounding test or its own rules. The
revised list was not re-tested in a live session for this copy; the
author's repository records a test on 14 October 2026 in which a write to
`reviews/` was refused and one to `notes/` allowed. Bash deny rules match
the command as written, not the same program by path or inside `sh -c`; the
documentation recommends the sandbox's network allowlist where the
restriction must hold.

## Scheduling files

`.github/workflows/weekly.yml` and `launchd/org.paragkamian.weekly-literature.plist`
are the two clocks the chapter describes; `docs/scheduling.md` compares them
with a third. The workflow sets `permissions: contents: write` (the default
token of a repository created since February 2023 is read-only), pins each
action to a full commit SHA with the release in a comment, and declares a
`concurrency` group so a manual and a scheduled run cannot write at once;
these three are what a reviewer should check in the agent's output. The
schedule needs the `OPENALEX_API_KEY` secret and is paused by GitHub after
sixty days without repository activity. The raw responses are uploaded as a
workflow artifact: in a public repository any signed-in GitHub user can
download it, and it is deleted after the retention period, so it is a
convenience, not a private or durable store; the durable record is the
normalised table with its excerpts and the MD5 sums in the log.

## Provenance and licence of the excerpts

`data/raw/2026-W41/` holds the responses of the public APIs of Europe PMC,
OpenAlex, arXiv, bioRxiv and Biodiversity PMC for the week of 5 to 11
October 2026 plus ten overlap days, as fetched on 14 October 2026, reduced
to the two topics by `R/freeze_week.R`, with every abstract cut to its first
forty words and marked `[cut to 40 words for the workshop copy]`;
`FROZEN.md` in the folder records the cut. The records are bibliographic
metadata (titles, author names, identifiers, dates, venues) and those
excerpts. OpenAlex publishes its metadata under CC0; the other services
publish theirs for reuse through their APIs under their own terms; the
abstract text remains its authors' and publishers', and the excerpts are
kept short and attributed to their DOI for that reason. Nothing here is a
substitute for the paper: do not cite a record without opening it. The
fixture week `2026-W00` is invented and carries no third-party text.

## The assistant layer

The skill needs a Claude Code session with the Consensus MCP server, and
Consensus is a paid subscription (the author's plan allowed 500 searches a
month in October 2026; the current terms are in the book's Appendix D). It
was not run in this workshop copy. The author ran it twice on 19 October
2026 for week 2026-W42 in the live repository
(<https://github.com/savvas-paragkamian/weekly-literature>, `tests/results.csv`
and `provenance/runs/`): the first run made no Consensus call, because the
session offered the tool under a name the skill had not pre-approved; the
second made 3 of the 16 configured queries, verified 6 Consensus papers
through `R/skill_verify.R`, and stopped to spare the month's remaining
searches; the pushback and injection tests were not run. Both runs used
Claude Opus 5.5 under Claude Code 2.1.303 and cost about three US dollars
each. Record your own runs in `tests/results.csv`; `tests/pushback.md` is
ready.

## Gold set and recall

`tests/gold.csv` lists twelve papers from the book's bibliography with the
date each was first published, taken from Crossref or the arXiv API on
22 October 2026. `tests/recall.R` scores a paper once it was first published
inside the recorded range and its window of two weeks has passed before the
end of the last recorded week, and compares the share found with a target of
0.90; both numbers are constants at the top of the script, for the author to
set. In this copy the recorded range is week 2026-W41 alone, so nothing can
be scored yet: eleven of the twelve papers predate it and one, Torresani et
al. (12 October 2026), is too recent for its window. The live repository
found that paper in week 2026-W42. The set is meant to roll: add every
paper you hear of elsewhere, with its date, for at least two months, and
read the score against the target. Without a target the gold set is a list,
not a test.

The assistant skill (`/weekly-literature 2026-W41` in Claude Code) needs a
Consensus login and has not been run in this copy (the author's two runs in
the live repository are described under "The assistant layer"); the
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
