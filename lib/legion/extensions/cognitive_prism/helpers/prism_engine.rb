# frozen_string_literal: true

module Legion
  module Extensions
    module CognitivePrism
      module Helpers
        class PrismEngine
          def initialize
            @beams      = {}
            @components = {}
          end

          def create_beam(domain:, content:, beam_id: nil)
            raise ArgumentError, "MAX_BEAMS (#{Constants::MAX_BEAMS}) reached" if @beams.size >= Constants::MAX_BEAMS

            id   = beam_id || SecureRandom.uuid
            beam = Beam.new(beam_id: id, domain: domain, content: content)
            @beams[id] = beam
            { success: true, beam_id: id, domain: domain }
          end

          def decompose(beam_id)
            beam = @beams.fetch(beam_id) { return { success: false, error: "Beam #{beam_id} not found" } }

            beam.decompose!
            beam.components.each { |c| @components["#{beam_id}:#{c.band}"] = c }

            Legion::Logging.debug "[cognitive_prism] decompose: beam=#{beam_id[0..7]} components=#{beam.components.size} purity=#{beam.purity.round(4)}"
            {
              success:         true,
              beam_id:         beam_id,
              component_count: beam.components.size,
              dominant_band:   beam.dominant_band,
              purity:          beam.purity
            }
          end

          def recompose(component_ids)
            selected = component_ids.filter_map { |cid| resolve_component(cid) }
            active   = selected.reject(&:faded?)
            return { success: true, synthesis: '', active_count: 0, total_count: 0 } if active.empty?

            synthesis = build_synthesis(active)
            { success: true, synthesis: synthesis, active_count: active.size, total_count: selected.size }
          end

          def attenuate_all!(rate: SpectralComponent::ATTENUATION_RATE_DEFAULT)
            count = 0
            @beams.each_value do |beam|
              beam.components.each do |c|
                c.attenuate!(rate: rate)
                count += 1
              end
            end
            { success: true, attenuated: count, rate: rate }
          end

          def dominant_bands
            result = Hash.new(0)
            @beams.each_value do |beam|
              band = beam.dominant_band
              result[band] += 1 if band
            end
            result.sort_by { |_, v| -v }.to_h
          end

          def most_intense(limit: 5)
            all_components = @beams.values.flat_map(&:components)
            all_components
              .sort_by { |c| -c.intensity }
              .first(limit)
              .map(&:to_h)
          end

          def spectral_report
            total_beams      = @beams.size
            total_components = @beams.values.sum { |b| b.components.size }
            decomposed_beams = @beams.count { |_, b| b.components.any? }

            avg_purity = if decomposed_beams.positive?
                           purity_sum = @beams.values.select { |b| b.components.any? }.sum(&:purity)
                           (purity_sum / decomposed_beams).round(10)
                         else
                           0.0
                         end

            {
              total_beams:      total_beams,
              decomposed_beams: decomposed_beams,
              total_components: total_components,
              dominant_bands:   dominant_bands,
              avg_purity:       avg_purity,
              most_intense:     most_intense(limit: 3)
            }
          end

          def get_beam(beam_id)
            @beams[beam_id]
          end

          def beam_count
            @beams.size
          end

          def clear!
            @beams.clear
            @components.clear
            self
          end

          private

          def resolve_component(cid)
            return @components[cid] if @components.key?(cid)

            @components.values.find { |c| component_key(c.band) == cid }
          end

          def build_synthesis(active)
            active.sort_by { |c| -c.intensity }
                  .map { |c| "[#{c.band}/#{c.wavelength}nm #{c.intensity.round(3)}]: #{c.content}" }
                  .join(' | ')
          end

          def component_key(band)
            band.to_s
          end
        end
      end
    end
  end
end
