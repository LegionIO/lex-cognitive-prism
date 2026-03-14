# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitivePrism::Helpers::Constants do
  describe 'SPECTRAL_BANDS' do
    it 'contains exactly 8 bands' do
      expect(described_class::SPECTRAL_BANDS.size).to eq(8)
    end

    it 'includes all expected bands in order' do
      expect(described_class::SPECTRAL_BANDS).to eq(
        %i[infrared red orange yellow green blue violet ultraviolet]
      )
    end

    it 'is frozen' do
      expect(described_class::SPECTRAL_BANDS).to be_frozen
    end
  end

  describe 'WAVELENGTH_RANGES' do
    it 'has a range for every spectral band' do
      described_class::SPECTRAL_BANDS.each do |band|
        expect(described_class::WAVELENGTH_RANGES).to have_key(band)
      end
    end

    it 'infrared covers 700..1000' do
      expect(described_class::WAVELENGTH_RANGES[:infrared]).to eq(700..1000)
    end

    it 'red covers 620..699' do
      expect(described_class::WAVELENGTH_RANGES[:red]).to eq(620..699)
    end

    it 'ultraviolet covers 10..379' do
      expect(described_class::WAVELENGTH_RANGES[:ultraviolet]).to eq(10..379)
    end

    it 'all ranges are Range objects' do
      described_class::WAVELENGTH_RANGES.each_value do |range|
        expect(range).to be_a(Range)
      end
    end
  end

  describe 'MAX_BEAMS' do
    it 'is 200' do
      expect(described_class::MAX_BEAMS).to eq(200)
    end
  end

  describe 'INTENSITY_LABELS' do
    it 'has 5 entries' do
      expect(described_class::INTENSITY_LABELS.size).to eq(5)
    end

    it 'labels trace for intensity 0.0..0.19' do
      entry = described_class::INTENSITY_LABELS.find { |e| e[:range].cover?(0.0) }
      expect(entry[:label]).to eq(:trace)
    end

    it 'labels brilliant for intensity 0.8..1.0' do
      entry = described_class::INTENSITY_LABELS.find { |e| e[:range].cover?(1.0) }
      expect(entry[:label]).to eq(:brilliant)
    end

    it 'labels moderate for intensity 0.5' do
      entry = described_class::INTENSITY_LABELS.find { |e| e[:range].cover?(0.5) }
      expect(entry[:label]).to eq(:moderate)
    end
  end

  describe 'PURITY_LABELS' do
    it 'has 5 entries' do
      expect(described_class::PURITY_LABELS.size).to eq(5)
    end

    it 'labels turbid for purity 0.0' do
      entry = described_class::PURITY_LABELS.find { |e| e[:range].cover?(0.0) }
      expect(entry[:label]).to eq(:turbid)
    end

    it 'labels prismatic for purity 1.0' do
      entry = described_class::PURITY_LABELS.find { |e| e[:range].cover?(1.0) }
      expect(entry[:label]).to eq(:prismatic)
    end

    it 'labels pure for purity 0.8' do
      entry = described_class::PURITY_LABELS.find { |e| e[:range].cover?(0.8) }
      expect(entry[:label]).to eq(:pure)
    end
  end
end
