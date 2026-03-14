# lex-cognitive-prism

Light prism decomposition model for LegionIO cognitive agents. Cognitive beams (ideas, problems, concepts) are decomposed into eight spectral bands across abstraction levels from concrete to transcendent. Bands can be attenuated or amplified; active components can be recomposed into a synthesized view.

## What It Does

- Eight spectral bands mapping to abstraction levels:
  - `infrared` → meta_contextual
  - `red` → concrete
  - `orange` → applied
  - `yellow` → structural
  - `green` → relational
  - `blue` → conceptual
  - `violet` → abstract
  - `ultraviolet` → transcendent
- Decompose: split content across bands with intensity based on chunk size × abstraction weight
- Purity score: uniformity of spectral distribution (high = balanced multi-perspective)
- Dominant band: highest-intensity spectral component
- Recompose: synthesize a view from selected active (non-faded) component IDs
- Attenuation: fade all components (global decay cycle)

## Usage

```ruby
# Create a beam
result = runner.create_beam(domain: :architecture,
                              content: 'decompose the service by bounded context applying DDD')

# Decompose into spectral components
runner.decompose(beam_id: result[:beam_id])
# => { success: true, component_count: 8, dominant_band: :red, purity: 0.72 }

# Get all beams dominant band distribution
runner.dominant_bands
# => { success: true, bands: { red: 3, blue: 1, violet: 1 } }

# Most intense components across all beams
runner.most_intense(limit: 3)

# Recompose from specific component IDs
runner.recompose(component_ids: ['beam-id:red', 'beam-id:blue', 'beam-id:violet'])
# => { success: true, synthesis: 'red(...): ... | blue(...): ... | violet(...): ...' }

# Attenuate all (periodic fade)
runner.attenuate_all(rate: 0.05)

# Status
runner.spectral_report
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
