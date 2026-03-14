# frozen_string_literal: true

module Legion
  module Extensions
    module CognitivePrism
      module Helpers
        class SpectralComponent
          ATTENUATION_RATE_DEFAULT = 0.05
          AMPLIFY_BOOST_DEFAULT    = 0.1
          DOMINANT_THRESHOLD       = 0.7
          FADED_THRESHOLD          = 0.1

          attr_reader :band, :wavelength, :content

          def initialize(band:, wavelength:, intensity:, content:)
            raise ArgumentError, "Unknown band: #{band}" unless Constants::SPECTRAL_BANDS.include?(band)

            range = Constants::WAVELENGTH_RANGES.fetch(band)
            raise ArgumentError, "Wavelength #{wavelength} out of range for #{band}" unless range.cover?(wavelength)

            @band       = band
            @wavelength = wavelength
            @intensity  = intensity.clamp(0.0, 1.0)
            @content    = content
          end

          def intensity
            @intensity.round(10)
          end

          def attenuate!(rate: ATTENUATION_RATE_DEFAULT)
            @intensity = (@intensity - rate.to_f.abs).clamp(0.0, 1.0)
            self
          end

          def amplify!(boost: AMPLIFY_BOOST_DEFAULT)
            @intensity = (@intensity + boost.to_f.abs).clamp(0.0, 1.0)
            self
          end

          def dominant?
            @intensity >= DOMINANT_THRESHOLD
          end

          def faded?
            @intensity <= FADED_THRESHOLD
          end

          def intensity_label
            Constants::INTENSITY_LABELS.find { |entry| entry[:range].cover?(@intensity) }&.fetch(:label, :unknown)
          end

          def to_h
            {
              band:            @band,
              wavelength:      @wavelength,
              intensity:       intensity,
              intensity_label: intensity_label,
              content:         @content,
              dominant:        dominant?,
              faded:           faded?
            }
          end
        end
      end
    end
  end
end
