# frozen_string_literal: true

module Legion
  module Extensions
    module CognitivePrism
      module Helpers
        class Beam
          BAND_MIDPOINTS = Constants::WAVELENGTH_RANGES.transform_values do |range|
            ((range.min + range.max) / 2.0).round
          end.freeze

          attr_reader :beam_id, :domain, :content, :components

          def initialize(beam_id:, domain:, content:)
            @beam_id    = beam_id
            @domain     = domain
            @content    = content
            @components = []
            @purity     = 0.0
          end

          def purity
            @purity.round(10)
          end

          def decompose!
            @components = []
            bands = assign_bands(content)

            bands.each do |band, band_content|
              wavelength = BAND_MIDPOINTS.fetch(band)
              intensity  = compute_intensity(band, band_content)
              @components << SpectralComponent.new(
                band:       band,
                wavelength: wavelength,
                intensity:  intensity,
                content:    band_content
              )
            end

            @purity = compute_purity
            self
          end

          def recompose
            return '' if @components.empty?

            active = @components.reject(&:faded?)
            sorted = active.sort_by { |c| -c.intensity }
            parts  = sorted.map { |c| "#{c.band}(#{c.intensity.round(3)}): #{summarize(c.content)}" }
            parts.join(' | ')
          end

          def dominant_band
            return nil if @components.empty?

            dominant = @components.select(&:dominant?)
            return dominant.max_by(&:intensity)&.band if dominant.any?

            @components.max_by(&:intensity)&.band
          end

          def spectral_balance
            return {} if @components.empty?

            total = @components.sum(&:intensity)
            return {} if total.zero?

            @components.each_with_object({}) do |c, acc|
              acc[c.band] = (c.intensity / total).round(10)
            end
          end

          def to_h
            {
              beam_id:          @beam_id,
              domain:           @domain,
              content:          @content,
              purity:           purity,
              purity_label:     purity_label,
              dominant_band:    dominant_band,
              spectral_balance: spectral_balance,
              component_count:  @components.size,
              components:       @components.map(&:to_h)
            }
          end

          private

          def assign_bands(raw_content)
            content_str = raw_content.is_a?(String) ? raw_content : raw_content.to_s
            total_length = content_str.length
            chunk_size   = total_length.positive? ? (total_length.to_f / Constants::SPECTRAL_BANDS.size).ceil : 1

            Constants::SPECTRAL_BANDS.each_with_index.each_with_object({}) do |(band, idx), acc|
              start_pos  = idx * chunk_size
              chunk      = total_length.positive? ? content_str[start_pos, chunk_size] || '' : ''
              acc[band]  = { raw: chunk, abstraction_level: abstraction_level_for(band) }
            end
          end

          def abstraction_level_for(band)
            abstraction_map = {
              infrared:    :meta_contextual,
              red:         :concrete,
              orange:      :applied,
              yellow:      :structural,
              green:       :relational,
              blue:        :conceptual,
              violet:      :abstract,
              ultraviolet: :transcendent
            }
            abstraction_map.fetch(band, :unknown)
          end

          def compute_intensity(band, band_content)
            raw     = band_content[:raw].to_s
            level   = band_content[:abstraction_level]
            base    = raw.empty? ? 0.1 : (raw.length.to_f / 20).clamp(0.1, 1.0)
            weight  = abstraction_weight(level)
            (base * weight).clamp(0.0, 1.0).round(10)
          end

          def abstraction_weight(level)
            weights = {
              meta_contextual: 0.6,
              concrete:        1.0,
              applied:         0.9,
              structural:      0.85,
              relational:      0.8,
              conceptual:      0.75,
              abstract:        0.7,
              transcendent:    0.5
            }
            weights.fetch(level, 0.7)
          end

          def compute_purity
            return 0.0 if @components.empty?

            intensities = @components.map(&:intensity)
            total       = intensities.sum
            return 0.0 if total.zero?

            max = intensities.max
            dominance_ratio = max / total
            n = Constants::SPECTRAL_BANDS.size.to_f
            uniformity = 1.0 - ((dominance_ratio - (1.0 / n)) * n / (n - 1)).abs
            uniformity.clamp(0.0, 1.0).round(10)
          end

          def purity_label
            Constants::PURITY_LABELS.find { |entry| entry[:range].cover?(@purity) }&.fetch(:label, :unknown)
          end

          def summarize(band_content)
            return '' unless band_content.is_a?(Hash)

            raw = band_content[:raw].to_s
            raw.length > 30 ? "#{raw[0, 30]}..." : raw
          end
        end
      end
    end
  end
end
