# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_prism/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-prism'
  spec.version       = Legion::Extensions::CognitivePrism::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Prism'
  spec.description   = 'Spectral decomposition of complex ideas into band-specific components — ' \
                       'white light in, rainbow out. Decompose ideas across abstraction wavelengths, ' \
                       'attenuate and amplify components, then recompose synthesized understanding.'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-prism'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = 'https://github.com/LegionIO/lex-cognitive-prism'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-cognitive-prism'
  spec.metadata['changelog_uri']     = 'https://github.com/LegionIO/lex-cognitive-prism'
  spec.metadata['bug_tracker_uri']   = 'https://github.com/LegionIO/lex-cognitive-prism/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
