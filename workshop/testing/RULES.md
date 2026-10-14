# Annotation rules used for key.csv

Decided before any model was run. Change them only before testing, never after.

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
