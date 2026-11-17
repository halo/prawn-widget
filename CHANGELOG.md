# Changelog

## 2.0.0 (unreleased)

Modernization on the road to `prawn-components`.

### Renamed

- Gem renamed `prawn-component` to `prawn-components` (the old name is taken on RubyGems).
- The Ruby API is unchanged: components still inherit from `Prawn::Component`.

### Changed

- Slot setters follow the current ViewComponent API: `with_title`, `with_article`, `with_articles`.
- The old bare setters (`title`, `article`) still work but emit a deprecation warning.
- Every slot has a predicate (`title?`, `articles?`).

### Removed

- String callables (`renders_one :x, "SomeClass"`) are gone; use a component class or a lambda.

### Tooling

- Tests moved from RSpec to Megatest (`bin/tests` runs the suite).
- Pinned to Ruby 4.0.9 (`.ruby-version`), refreshed `Gemfile.lock`.
- SPDX license headers in every Ruby file, singular SPDX `license` field in the gemspec.

## 1.0.0

- First release: ViewComponent-style slots for Prawn.
- `renders_one` and `renders_many` with bare setters, `Slot#draw`, `render_in` and `call_in`.
- Params and options via `dry-initializer` (through a vendored `method_object` copy).
