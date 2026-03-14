# frozen_string_literal: true

module Legion
  module Extensions
    module CognitivePrism
      module Helpers
        module Constants
          SPECTRAL_BANDS = %i[infrared red orange yellow green blue violet ultraviolet].freeze

          WAVELENGTH_RANGES = {
            infrared:    700..1000,
            red:         620..699,
            orange:      590..619,
            yellow:      560..589,
            green:       490..559,
            blue:        450..489,
            violet:      380..449,
            ultraviolet: 10..379
          }.freeze

          MAX_BEAMS = 200

          INTENSITY_LABELS = [
            { range: 0.0..0.19,  label: :trace },
            { range: 0.2..0.39,  label: :faint },
            { range: 0.4..0.59,  label: :moderate },
            { range: 0.6..0.79,  label: :strong },
            { range: 0.8..1.0,   label: :brilliant }
          ].freeze

          PURITY_LABELS = [
            { range: 0.0..0.24,  label: :turbid },
            { range: 0.25..0.49, label: :murky },
            { range: 0.5..0.74,  label: :clear },
            { range: 0.75..0.89, label: :pure },
            { range: 0.9..1.0,   label: :prismatic }
          ].freeze
        end
      end
    end
  end
end
