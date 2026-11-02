# Collembola survey, northern Crete (invented teaching data)

A practice project for the chapter "A First Agent Session". The records in
`data/raw/occurrences.csv` are invented and contain deliberate problems.
Do not publish or analyse them.

- `data/raw/occurrences.csv`: 23 occurrence records from five stations (S1 to
  S5). Columns: record_id, station, date, scientific_name, count, habitat,
  occurrence_status (present or absent, the Darwin Core term occurrenceStatus),
  effort (sampling method or effort as written), latitude and longitude
  (decimal degrees, WGS84, EPSG:4326), notes. One record is a non-detection: a
  species searched for and not found, with occurrence_status = absent and no
  count. An empty count on such a row is not a missing value.
- `data/raw/checklist.csv`: the accepted species names for this survey, fixed
  on 11 October 2026. In real work the names would be matched against a
  backbone (GBIF Backbone, Catalogue of Life, WoRMS) and its version or
  download date would be recorded in the log.
- `data/processed/`: files derived by the scripts. Regenerate them; never edit
  by hand.
- `scripts/`: numbered R scripts, run in order with `Rscript scripts/01_check.R`.
- `logs/`: one Markdown log per agent session.

The last three folders hold a `.gitkeep` file so that they exist in a fresh
checkout.

## Permissions

`opencode.json` holds the configuration used when the session was tested on
11 October 2026: every edit and every command is denied unless it matches an
allow rule (edits under `scripts/`, `data/processed/` and `logs/`; the command
`Rscript scripts/*`), and web fetches are denied. In OpenCode the last
matching rule wins (<https://opencode.ai/docs/permissions/>, checked
2 November 2026). Three deny rules were added on 2 November 2026, for
`git reset --hard`, `git clean` and `git push`, so that an agent cannot
discard the checkpoint or rewrite the remote copy. They change nothing while
`"*"` is `"deny"`, and they keep those commands refused if you relax it to
`"ask"`.

`.claude/settings.json` holds the equivalent rules for Claude Code, with the
same three Git rules. In Claude Code a deny rule wins over an allow rule, and
in the default mode anything that no rule covers is asked about; its
`dontAsk` mode refuses such calls instead. Neither file nor mode was tested:
the Claude Code track was not run.

Two limits. A rule on a command's arguments is not a security boundary.
Claude Code's documentation states that `Bash(curl *)` stops
`curl https://example.com` but not `/usr/bin/curl https://example.com` or
`sh -c 'curl https://example.com'` (<https://code.claude.com/docs/en/permissions>,
checked 22 October 2026), and a script the agent writes and then runs is not
covered by the harness's tool rules at all. Pair these rules with the
harness's sandbox where it has one, or run the session in a container without
network access. Claude Code's sandbox is off by default and `/sandbox` turns
it on; it runs on macOS, Linux and WSL2, not on native Windows, and by
default lets commands write anywhere in the project folder, so `data/raw`
still needs the read-only step below
(<https://code.claude.com/docs/en/sandboxing>, checked 2 November 2026; not
tested here). Second, the rules bind the harness, not the model: the model
may still propose what the rules forbid, and the harness refuses it. A model
that asks in the chat before acting is making a choice, not obeying a
control; in the 11 October test the model asked before writing a file the
configuration would have let it write.

## Read-only raw data

macOS and Linux: `chmod -R a-w data/raw`. Windows: in File Explorer,
right-click `data\raw`, choose Properties, tick Read-only and apply it to the
files inside; or in PowerShell, `attrib +R data\raw\*.* /S`. From R on any
system: `Sys.chmod(list.files("data/raw", full.names = TRUE), "0444")`. A
process running as you can undo any of these, which is why the checkpoint
commit and your review remain the real protection.
