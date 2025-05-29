# Changelog

## v0.3.0 — 2025-05-29

* Add escape-hatch for custom key value formatting

  OpenTelemetry libraries add some metadata to logger, but they add them as charlists
  (`otel_span_id` and `otel_trace_id`) which ends up as a list of integers in the JSON log. For
  log correlation with some services (such as Datadog), they need these IDs to be in hex format,
  which means I need to be able to hook into the log formatting for these particular keys and
  values and format them.

  This adds a compile-config-based escape hatch for formatting values in the logger message.

## v0.2.0 — 2024-09-23

* Handle formatting improper lists

  Improper lists can't be handled by standard iterators such as `Enum.map/2`, which made it
  impossible to convert them into a standard, loggable format.

* Check for implementation of `Jason.Encoder` for structs

  If a struct has a custom implementation of `Jason.Encoder` we'll clean the internals but put
  everything back where we found it so the custom implementation could redact fields, for example.

## v0.1.2 — 2022-01-12

* Inspect non-atom/string keys

  Instead of exploding on map keys in Jason if they were a list like `[:foo, "bar"]` or a map,
  etc., we'll allow strings or atoms as before, but `inspect` otherwise.

## v0.1.1 — 2022-12-06

* Ensure full keyword list before encoding as map

  This fixes situations where there are erlang-style option lists with both atoms and tuples, e.g.
  `[{Mod, []}, :enabled]`

## v0.1.0 — 2022-10-10

Initial release with a translator and formatter for structured JSON logs.
