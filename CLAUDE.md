# lex-cognitive-prism

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`

## Purpose

Light prism metaphor for cognitive decomposition and synthesis. A beam of cognitive content (idea, concept, problem) is passed through a prism to decompose it into spectral components across eight bands: infrared (meta_contextual), red (concrete), orange (applied), yellow (structural), green (relational), blue (conceptual), violet (abstract), ultraviolet (transcendent). Each band maps to an abstraction level. Components can be attenuated (faded) or amplified (boosted). Decomposed beams can be recomposed from selected active components into a synthesized view.

## Gem Info

- **Gem name**: `lex-cognitive-prism`
- **Module**: `Legion::Extensions::CognitivePrism`
- **Version**: `0.1.0`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/cognitive_prism/
  version.rb
  client.rb
  helpers/
    constants.rb
    spectral_component.rb
    beam.rb
    prism_engine.rb
  runners/
    cognitive_prism.rb
```

## Key Constants

| Constant | Value | Purpose |
|---|---|---|
| `SPECTRAL_BANDS` | `%i[infrared red orange yellow green blue violet ultraviolet]` | Eight cognitive abstraction levels |
| `WAVELENGTH_RANGES` | hash | Wavelength integer ranges per band (700–1000 for infrared down to 10–379 for ultraviolet) |
| `MAX_BEAMS` | `200` | Per-engine beam capacity (raises `ArgumentError` at limit) |
| `INTENSITY_LABELS` | array of range/label hashes | From `:trace` to `:brilliant` |
| `PURITY_LABELS` | array of range/label hashes | From `:turbid` to `:prismatic` |

## Helpers

### `Helpers::SpectralComponent`
One spectral band of a decomposed beam. Has `band`, `wavelength`, `intensity` (0.0–1.0), and `content` (chunk of original content for that band).

Constants on the class: `ATTENUATION_RATE_DEFAULT = 0.05`, `AMPLIFY_BOOST_DEFAULT = 0.1`, `DOMINANT_THRESHOLD = 0.7`, `FADED_THRESHOLD = 0.1`.

- `attenuate!(rate:)` — reduces intensity
- `amplify!(boost:)` — increases intensity
- `dominant?` — intensity >= 0.7
- `faded?` — intensity <= 0.1
- `intensity_label`
- `to_h`

### `Helpers::Beam`
Cognitive content beam awaiting or having undergone decomposition. Has `beam_id`, `domain`, `content`, `components` (array), and `purity`.

- `decompose!` — chunks content by band using `assign_bands`; assigns abstraction levels; computes intensity per band via `compute_intensity` (base from chunk length × abstraction weight); computes purity
- `recompose` → string synthesizing active non-faded components sorted by intensity
- `dominant_band` → band with highest intensity (or first dominant band)
- `spectral_balance` → hash of `band => fraction_of_total`
- `purity` — uniformity metric: 1.0 = perfectly even distribution; 0.0 = single dominant band. Formula normalizes dominance ratio against ideal uniform ratio.
- `to_h`

**Abstraction weights** (applied in `compute_intensity`): concrete = 1.0, applied = 0.9, structural = 0.85, relational = 0.8, conceptual = 0.75, abstract = 0.7, meta_contextual = 0.6, transcendent = 0.5. Concrete bands produce higher intensity from same content length.

### `Helpers::PrismEngine`
Top-level store.

- `create_beam(domain:, content:, beam_id:)` → creation result or raises `ArgumentError` at `MAX_BEAMS`
- `decompose(beam_id)` → decomposition result with `component_count`, `dominant_band`, `purity`
- `recompose(component_ids)` → synthesis result from selected component IDs
- `attenuate_all!(rate:)` → count of attenuated components
- `dominant_bands` → frequency hash of which bands dominate across all beams
- `most_intense(limit:)` → top N components across all beams
- `spectral_report` → aggregate stats
- `get_beam(beam_id)` → beam object
- `clear!` → empties all beams and components

## Runners

Module: `Runners::CognitivePrism`

| Runner Method | Description |
|---|---|
| `create_beam(domain:, content:, beam_id:)` | Register a new beam |
| `decompose(beam_id:)` | Decompose beam into spectral components |
| `recompose(component_ids:)` | Synthesize from selected components |
| `attenuate_all(rate:)` | Attenuate all components (decay) |
| `dominant_bands` | Frequency of dominant bands across all beams |
| `most_intense(limit:)` | Top N most intense components |
| `spectral_report` | Aggregate stats |

All runners return `{success: true/false, ...}` hashes. Error responses on `ArgumentError` (e.g., capacity exceeded, unknown band).

## Integration Points

- `lex-tick` `action_selection` phase: decompose the current situation → dominant band determines reasoning style (concrete band dominant → ground action in facts; abstract band dominant → conceptual reasoning)
- `lex-memory`: decomposed beams can be stored per-band as semantic traces with band as domain tag
- `lex-emotion`: ultraviolet (transcendent) band intensity reflects metacognitive depth; can influence arousal
- Purity score: high purity = balanced multi-perspective analysis; low purity = narrow single-mode thinking

## Development Notes

- `Client` instantiates `@default_engine = Helpers::PrismEngine.new` via runner memoization
- `decompose!` splits content by equal chunks across 8 bands: `chunk_size = content.length / 8` (ceiling). Short content means small chunks per band.
- Purity formula: `1.0 - |(dominance_ratio - 1/n) * n / (n-1)|` — measures deviation from perfect uniformity; high purity ≠ high clarity, it means balanced spectral distribution
- `recompose(component_ids)` looks up IDs in `@components` hash keyed by `"#{beam_id}:#{band}"` format
- `MAX_BEAMS = 200` raises `ArgumentError` (not returns error hash) — rescue is in the runner layer
