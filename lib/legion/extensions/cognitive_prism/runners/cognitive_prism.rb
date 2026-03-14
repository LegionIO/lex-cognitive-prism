# frozen_string_literal: true

module Legion
  module Extensions
    module CognitivePrism
      module Runners
        module CognitivePrism
          extend self

          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def create_beam(domain:, content:, beam_id: nil, engine: nil, **)
            prism = engine || default_engine
            prism.create_beam(domain: domain, content: content, beam_id: beam_id)
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_prism] create_beam failed: #{e.message}"
            { success: false, error: e.message }
          end

          def decompose(beam_id:, engine: nil, **)
            prism = engine || default_engine
            prism.decompose(beam_id)
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_prism] decompose failed: #{e.message}"
            { success: false, error: e.message }
          end

          def recompose(component_ids:, engine: nil, **)
            prism = engine || default_engine
            prism.recompose(component_ids)
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_prism] recompose failed: #{e.message}"
            { success: false, error: e.message }
          end

          def attenuate_all(rate: Helpers::SpectralComponent::ATTENUATION_RATE_DEFAULT, engine: nil, **)
            prism = engine || default_engine
            prism.attenuate_all!(rate: rate)
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_prism] attenuate_all failed: #{e.message}"
            { success: false, error: e.message }
          end

          def dominant_bands(engine: nil, **)
            prism = engine || default_engine
            { success: true, bands: prism.dominant_bands }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def most_intense(limit: 5, engine: nil, **)
            prism = engine || default_engine
            { success: true, components: prism.most_intense(limit: limit) }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def spectral_report(engine: nil, **)
            prism = engine || default_engine
            report = prism.spectral_report
            { success: true }.merge(report)
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          private

          def default_engine
            @default_engine ||= Helpers::PrismEngine.new
          end
        end
      end
    end
  end
end
