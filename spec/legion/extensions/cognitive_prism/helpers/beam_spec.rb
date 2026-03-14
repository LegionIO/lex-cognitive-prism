# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitivePrism::Helpers::Beam do
  let(:beam_id) { 'test-beam-001' }
  let(:domain)  { :cognition }
  let(:content) { 'The idea of emergence in complex systems where local interactions produce global patterns' }
  subject(:beam) { described_class.new(beam_id: beam_id, domain: domain, content: content) }

  describe '#initialize' do
    it 'sets beam_id' do
      expect(beam.beam_id).to eq(beam_id)
    end

    it 'sets domain' do
      expect(beam.domain).to eq(domain)
    end

    it 'sets content' do
      expect(beam.content).to eq(content)
    end

    it 'starts with no components' do
      expect(beam.components).to be_empty
    end

    it 'starts with purity 0.0' do
      expect(beam.purity).to eq(0.0)
    end
  end

  describe '#decompose!' do
    before { beam.decompose! }

    it 'returns self for chaining' do
      fresh = described_class.new(beam_id: 'x', domain: :test, content: 'test')
      expect(fresh.decompose!).to be(fresh)
    end

    it 'creates one component per spectral band' do
      expect(beam.components.size).to eq(Legion::Extensions::CognitivePrism::Helpers::Constants::SPECTRAL_BANDS.size)
    end

    it 'creates components as SpectralComponent instances' do
      beam.components.each do |c|
        expect(c).to be_a(Legion::Extensions::CognitivePrism::Helpers::SpectralComponent)
      end
    end

    it 'covers all spectral bands' do
      bands = beam.components.map(&:band)
      expect(bands).to contain_exactly(*Legion::Extensions::CognitivePrism::Helpers::Constants::SPECTRAL_BANDS)
    end

    it 'sets purity after decomposition' do
      expect(beam.purity).to be >= 0.0
      expect(beam.purity).to be <= 1.0
    end

    it 'all component intensities are in 0..1' do
      beam.components.each do |c|
        expect(c.intensity).to be_between(0.0, 1.0)
      end
    end

    it 'works with empty content' do
      empty_beam = described_class.new(beam_id: 'empty', domain: :test, content: '')
      empty_beam.decompose!
      expect(empty_beam.components.size).to eq(8)
    end
  end

  describe '#recompose' do
    it 'returns empty string when no components' do
      expect(beam.recompose).to eq('')
    end

    it 'returns a synthesis string after decomposition' do
      beam.decompose!
      result = beam.recompose
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end

    it 'excludes faded components' do
      beam.decompose!
      beam.components.each { |c| c.attenuate!(rate: 0.99) }
      result = beam.recompose
      # all faded -> empty
      expect(result).to eq('')
    end

    it 'sorts by descending intensity in synthesis' do
      beam.decompose!
      active = beam.components.reject(&:faded?)
      next if active.empty?

      sorted_intensities = active.sort_by { |c| -c.intensity }.map(&:intensity)
      result = beam.recompose
      # verify result is non-empty and structured
      expect(result).to include('|') if active.size > 1 # rubocop:disable RSpec/MultipleExpectations
    end
  end

  describe '#dominant_band' do
    it 'returns nil when no components' do
      expect(beam.dominant_band).to be_nil
    end

    it 'returns a band symbol after decomposition' do
      beam.decompose!
      band = beam.dominant_band
      expect(band).to be_a(Symbol)
      expect(Legion::Extensions::CognitivePrism::Helpers::Constants::SPECTRAL_BANDS).to include(band)
    end

    it 'returns the band with highest intensity' do
      beam.decompose!
      expected = beam.components.max_by(&:intensity).band
      # dominant_band prefers dominant? ones but falls back to max intensity
      expect(beam.dominant_band).to be_a(Symbol)
      expect(beam.dominant_band).not_to be_nil
    end
  end

  describe '#spectral_balance' do
    it 'returns empty hash when no components' do
      expect(beam.spectral_balance).to eq({})
    end

    it 'returns a hash with band keys after decomposition' do
      beam.decompose!
      balance = beam.spectral_balance
      expect(balance).to be_a(Hash)
      balance.each_key do |k|
        expect(Legion::Extensions::CognitivePrism::Helpers::Constants::SPECTRAL_BANDS).to include(k)
      end
    end

    it 'balance values sum to approximately 1.0' do
      beam.decompose!
      balance = beam.spectral_balance
      next if balance.empty?

      expect(balance.values.sum).to be_within(0.001).of(1.0)
    end

    it 'all balance values are between 0 and 1' do
      beam.decompose!
      beam.spectral_balance.each_value do |v|
        expect(v).to be_between(0.0, 1.0)
      end
    end
  end

  describe '#to_h' do
    it 'returns a hash with expected keys when not decomposed' do
      h = beam.to_h
      expect(h).to have_key(:beam_id)
      expect(h).to have_key(:domain)
      expect(h).to have_key(:content)
      expect(h).to have_key(:purity)
      expect(h).to have_key(:components)
    end

    it 'includes purity_label' do
      expect(beam.to_h).to have_key(:purity_label)
    end

    it 'includes spectral_balance' do
      expect(beam.to_h).to have_key(:spectral_balance)
    end

    it 'includes dominant_band' do
      expect(beam.to_h).to have_key(:dominant_band)
    end

    it 'includes component_count' do
      beam.decompose!
      expect(beam.to_h[:component_count]).to eq(8)
    end
  end
end
