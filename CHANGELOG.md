# Changelog

## v0.1.1 — 2022-12-06

* Ensure full keyword list before encoding as map

  This fixes situations where there are erlang-style option lists with both
  atoms and tuples, e.g. `[{Mod, []}, :enabled]`

## v0.1.0 — 2022-10-10

Initial release with a translator and formatter for structured JSON logs.
