# Annotation rules used for key/key.csv and key/key_heldout.csv

Revised 22 October 2026, before any model was run on the held-out notes.
The rules of 11 October 2026 are kept at the end; they produced the runs in
`answers/testing-run-2026-10-11/`. Change rules only before testing, never
after.

- One row per note. A note records at most one species: the one with a
  specimen in hand. If a note reports a species found and another searched
  for without success, record the species found and keep the search in
  `effort`.
- station: S1 to S5 as written. A place without a station number is empty.
- date: YYYY-MM-DD, whatever the format in the note.
- species: copied exactly as written, misspellings and qualifiers such as
  "cf." included. Name checking is a separate step. When status is absent,
  the species searched for. Empty when status is not_sampled.
- count: only when an exact number is stated, in digits or words ("two",
  "a single" is 1, "x3", "n = 7", "16 ind."). Empty for a rough number
  ("roughly a dozen", "about 30") and whenever status is not present.
  Never 0: a lost sample or an unsuccessful search is not a count of zero.
- habitat: one of litter, soil, moss, bark, compost, cave. Litter of any kind
  (pine needles, grass litter, oak litter, leaf litter) is litter; a soil
  core, humus or bare soil is soil; a moss cushion is moss; bark or under
  bark is bark. Empty when status is not_sampled.
- status: present when a specimen was sorted, seen or counted; absent when a
  species was searched for, none was found, and nothing else was recorded;
  not_sampled when no sample was taken or the sample was lost before sorting.
- effort: the sampling effort or method as written, trimmed to the phrase
  ("Berlese sample ran 48 h", "three oaks", "two pitfall traps, emptied
  after 24 h"). Empty when none is stated. The reason for a failed sample
  ("the funnel flooded") is not effort.
- count_qualifier: exact when the count covers the whole sample; partial
  when the number covers only part of it ("40 counted in the first tray");
  approximate when the note gives a rough number, in which case count is
  empty. Empty when no number is given.
- id_qualifier: tentative when the note doubts the identification
  ("identification tentative", "probably", "cf."). Empty otherwise.
- A species searched for but not found is recorded, with status absent, the
  habitat searched and the effort spent, unless another species was found in
  the same note.

Scoring: every field is compared exactly after trimming, except `effort`,
which is free text and counts as correct when the key's phrase and the
output contain each other after lower-casing and removing punctuation.

## Rules of 11 October 2026 (superseded)

Decided before any model was run. Fields: station, date, species, count,
habitat.

- One row per note. A note records at most one species.
- station: S1 to S5 as written. A place without a station number is empty.
- date: YYYY-MM-DD.
- species: copied exactly as written, misspellings included. Name checking
  is a separate step. Empty if no specimen was sorted.
- count: only when an exact number is stated, in digits or words.
  "Roughly a dozen" is empty, not 12.
- habitat: one of litter, soil, moss, bark, compost, cave. Pine needles and
  grass litter are litter. Empty if no sample was taken.
- A species searched for but not found is not recorded.

The last rule discarded a non-detection with stated effort (N06), and a
lost or unsampled station could only be told from a true absence by its
empty cells. The revision of 22 October adds status, effort and the two
qualifiers so that these cases are recorded rather than dropped.
