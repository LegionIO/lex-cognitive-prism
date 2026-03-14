# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitivePrism::Runners::CognitivePrism do
  let(:engine) { Legion::Extensions::CognitivePrism::Helpers::PrismEngine.new }

  describe '#create_beam' do
    it 'creates a beam via the provided engine' do
      result = described_class.create_beam(domain: :science, content: 'relativity theory', engine: engine)
      expect(result[:success]).to be true
      expect(result[:domain]).to eq(:science)
    end

    it 'returns beam_id' do
      result = described_class.create_beam(domain: :art, content: 'impressionism', engine: engine)
      expect(result[:beam_id]).to be_a(String)
    end

    it 'returns failure on ArgumentError (MAX_BEAMS)' do
      stub_const('Legion::Extensions::CognitivePrism::Helpers::Constants::MAX_BEAMS', 0)
      result = described_class.create_beam(domain: :d, content: 'x', engine: engine)
      expect(result[:success]).to be false
      expect(result[:error]).to be_a(String)
    end

    it 'accepts extra kwargs via ** splat' do
      result = described_class.create_beam(domain: :test, content: 'splat test', engine: engine, extra: :ignored)
      expect(result[:success]).to be true
    end
  end

  describe '#decompose' do
    let(:beam_id) { described_class.create_beam(domain: :physics, content: 'wave-particle duality', engine: engine)[:beam_id] }

    it 'returns success with component count' do
      result = described_class.decompose(beam_id: beam_id, engine: engine)
      expect(result[:success]).to be true
      expect(result[:component_count]).to eq(8)
    end

    it 'returns failure for unknown beam_id' do
      result = described_class.decompose(beam_id: 'ghost', engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '#recompose' do
    let(:beam_id) do
      id = described_class.create_beam(domain: :math, content: 'topology and manifolds', engine: engine)[:beam_id]
      described_class.decompose(beam_id: id, engine: engine)
      id
    end

    it 'returns success' do
      result = described_class.recompose(component_ids: [], engine: engine)
      expect(result[:success]).to be true
    end

    it 'accepts extra kwargs' do
      result = described_class.recompose(component_ids: [], engine: engine, meta: :data)
      expect(result[:success]).to be true
    end
  end

  describe '#attenuate_all' do
    before do
      id = described_class.create_beam(domain: :d, content: 'idea to attenuate', engine: engine)[:beam_id]
      described_class.decompose(beam_id: id, engine: engine)
    end

    it 'returns success' do
      result = described_class.attenuate_all(engine: engine)
      expect(result[:success]).to be true
    end

    it 'reports attenuated count' do
      result = described_class.attenuate_all(engine: engine)
      expect(result[:attenuated]).to eq(8)
    end

    it 'accepts a custom rate' do
      result = described_class.attenuate_all(rate: 0.2, engine: engine)
      expect(result[:rate]).to eq(0.2)
    end
  end

  describe '#dominant_bands' do
    it 'returns success with bands hash' do
      result = described_class.dominant_bands(engine: engine)
      expect(result[:success]).to be true
      expect(result[:bands]).to be_a(Hash)
    end

    it 'bands hash has values after decomposition' do
      id = described_class.create_beam(domain: :d, content: 'bright idea', engine: engine)[:beam_id]
      described_class.decompose(beam_id: id, engine: engine)
      result = described_class.dominant_bands(engine: engine)
      expect(result[:bands]).not_to be_empty
    end
  end

  describe '#most_intense' do
    before do
      id = described_class.create_beam(domain: :d, content: 'intense thought', engine: engine)[:beam_id]
      described_class.decompose(beam_id: id, engine: engine)
    end

    it 'returns success with components array' do
      result = described_class.most_intense(engine: engine)
      expect(result[:success]).to be true
      expect(result[:components]).to be_an(Array)
    end

    it 'respects the limit parameter' do
      result = described_class.most_intense(limit: 3, engine: engine)
      expect(result[:components].size).to be <= 3
    end
  end

  describe '#spectral_report' do
    it 'returns success with report keys' do
      result = described_class.spectral_report(engine: engine)
      expect(result[:success]).to be true
      expect(result).to have_key(:total_beams)
      expect(result).to have_key(:decomposed_beams)
    end

    it 'includes avg_purity' do
      result = described_class.spectral_report(engine: engine)
      expect(result).to have_key(:avg_purity)
    end
  end
end
