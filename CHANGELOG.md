# Changelog

## v0.1.2 — 2022-01-12

* Inspect non-atom/string keys

  Instead of exploding on map keys in Jason if they were a list like `[:foo,
  "bar"]` or a map, etc., we'll allow strings or atoms as before, but `inspect`
  otherwise.

* Check for implementation of Jason.Encoder for structs

  If a struct has a custom implementation of `Jason.Encoder` we'll clean the
  internals but put everything back where we found it so the custom
  implementation could redact fields, for example.

## v0.1.1 — 2022-12-06

* Ensure full keyword list before encoding as map

  This fixes situations where there are erlang-style option lists with both
  atoms and tuples, e.g. `[{Mod, []}, :enabled]`

## v0.1.0 — 2022-10-10

Initial release with a translator and formatter for structured JSON logs.
