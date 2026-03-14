# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitivePrism::Helpers::PrismEngine do
  subject(:engine) { described_class.new }

  describe '#create_beam' do
    it 'creates a beam and returns success' do
      result = engine.create_beam(domain: :cognition, content: 'test idea')
      expect(result[:success]).to be true
      expect(result[:beam_id]).to be_a(String)
      expect(result[:domain]).to eq(:cognition)
    end

    it 'uses provided beam_id when given' do
      result = engine.create_beam(domain: :logic, content: 'custom id', beam_id: 'my-beam')
      expect(result[:beam_id]).to eq('my-beam')
    end

    it 'generates a uuid beam_id when not provided' do
      result = engine.create_beam(domain: :logic, content: 'auto id')
      expect(result[:beam_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores the created beam' do
      result = engine.create_beam(domain: :test, content: 'stored')
      expect(engine.beam_count).to eq(1)
      expect(engine.get_beam(result[:beam_id])).not_to be_nil
    end

    it 'raises ArgumentError when MAX_BEAMS is reached' do
      stub_const('Legion::Extensions::CognitivePrism::Helpers::Constants::MAX_BEAMS', 2)
      engine.create_beam(domain: :d, content: 'a')
      engine.create_beam(domain: :d, content: 'b')
      expect { engine.create_beam(domain: :d, content: 'c') }.to raise_error(ArgumentError, /MAX_BEAMS/)
    end

    it 'increments beam_count each time' do
      3.times { |i| engine.create_beam(domain: :test, content: "idea #{i}") }
      expect(engine.beam_count).to eq(3)
    end
  end

  describe '#decompose' do
    let(:beam_id) { engine.create_beam(domain: :science, content: 'quantum entanglement across spacetime')[:beam_id] }

    it 'returns success with component count' do
      result = engine.decompose(beam_id)
      expect(result[:success]).to be true
      expect(result[:component_count]).to eq(8)
    end

    it 'returns dominant_band' do
      result = engine.decompose(beam_id)
      expect(result[:dominant_band]).to be_a(Symbol)
    end

    it 'returns purity value' do
      result = engine.decompose(beam_id)
      expect(result[:purity]).to be_between(0.0, 1.0)
    end

    it 'returns error when beam not found' do
      result = engine.decompose('nonexistent-id')
      expect(result[:success]).to be false
      expect(result[:error]).to include('not found')
    end
  end

  describe '#recompose' do
    before do
      @id = engine.create_beam(domain: :philosophy, content: 'consciousness and qualia')[:beam_id]
      engine.decompose(@id)
    end

    it 'returns success with synthesis string' do
      beam = engine.get_beam(@id)
      non_faded = beam.components.reject(&:faded?)
      ids = non_faded.map { |c| "#{@id}:#{c.band}" }
      result = engine.recompose(ids)
      expect(result[:success]).to be true
    end

    it 'returns empty synthesis for empty component_ids' do
      result = engine.recompose([])
      expect(result[:success]).to be true
      expect(result[:synthesis]).to eq('')
    end

    it 'returns empty synthesis for unknown component ids' do
      result = engine.recompose(['fake:red', 'fake:blue'])
      expect(result[:success]).to be true
      expect(result[:active_count]).to eq(0)
    end
  end

  describe '#attenuate_all!' do
    before do
      id1 = engine.create_beam(domain: :d, content: 'idea one')[:beam_id]
      id2 = engine.create_beam(domain: :d, content: 'idea two')[:beam_id]
      engine.decompose(id1)
      engine.decompose(id2)
    end

    it 'returns success with count of attenuated components' do
      result = engine.attenuate_all!
      expect(result[:success]).to be true
      expect(result[:attenuated]).to eq(16)
    end

    it 'returns the rate used' do
      result = engine.attenuate_all!(rate: 0.05)
      expect(result[:rate]).to eq(0.05)
    end

    it 'reduces intensities of all components' do
      id = engine.create_beam(domain: :test, content: 'bright idea')[:beam_id]
      engine.decompose(id)
      beam = engine.get_beam(id)
      before_intensities = beam.components.map(&:intensity).dup
      engine.attenuate_all!(rate: 0.2)
      after_intensities = beam.components.map(&:intensity)
      before_intensities.zip(after_intensities).each do |before, after|
        expect(after).to be <= before
      end
    end

    it 'works when no beams have been decomposed' do
      fresh = described_class.new
      fresh.create_beam(domain: :d, content: 'x')
      result = fresh.attenuate_all!
      expect(result[:success]).to be true
      expect(result[:attenuated]).to eq(0)
    end
  end

  describe '#dominant_bands' do
    it 'returns empty hash when no beams' do
      expect(engine.dominant_bands).to eq({})
    end

    it 'returns a hash with band counts after decomposition' do
      id = engine.create_beam(domain: :test, content: 'a complex idea about systems')[:beam_id]
      engine.decompose(id)
      bands = engine.dominant_bands
      expect(bands).to be_a(Hash)
    end

    it 'counts multiple beams correctly' do
      2.times do |i|
        id = engine.create_beam(domain: :test, content: "idea #{i}" * 20)[:beam_id]
        engine.decompose(id)
      end
      bands = engine.dominant_bands
      expect(bands.values.sum).to eq(2)
    end
  end

  describe '#most_intense' do
    before do
      3.times do |i|
        id = engine.create_beam(domain: :test, content: "concept #{i} with depth")[:beam_id]
        engine.decompose(id)
      end
    end

    it 'returns up to limit components' do
      result = engine.most_intense(limit: 5)
      expect(result.size).to be <= 5
    end

    it 'returns component hashes' do
      result = engine.most_intense(limit: 3)
      result.each do |item|
        expect(item).to have_key(:band)
        expect(item).to have_key(:intensity)
      end
    end

    it 'returns fewer items than limit when not enough components' do
      fresh = described_class.new
      id = fresh.create_beam(domain: :d, content: 'x')[:beam_id]
      fresh.decompose(id)
      result = fresh.most_intense(limit: 100)
      expect(result.size).to eq(8)
    end

    it 'returns components sorted by descending intensity' do
      result = engine.most_intense(limit: 10)
      intensities = result.map { |c| c[:intensity] }
      expect(intensities).to eq(intensities.sort.reverse)
    end
  end

  describe '#spectral_report' do
    it 'returns expected keys' do
      report = engine.spectral_report
      expect(report).to have_key(:total_beams)
      expect(report).to have_key(:decomposed_beams)
      expect(report).to have_key(:total_components)
      expect(report).to have_key(:dominant_bands)
      expect(report).to have_key(:avg_purity)
      expect(report).to have_key(:most_intense)
    end

    it 'reports 0 beams on fresh engine' do
      expect(engine.spectral_report[:total_beams]).to eq(0)
    end

    it 'reports correct beam counts after creation and decomposition' do
      2.times { |i| engine.create_beam(domain: :d, content: "idea #{i}") }
      id = engine.create_beam(domain: :d, content: 'decomposed')[:beam_id]
      engine.decompose(id)
      report = engine.spectral_report
      expect(report[:total_beams]).to eq(3)
      expect(report[:decomposed_beams]).to eq(1)
    end

    it 'avg_purity is 0.0 when no decomposed beams' do
      engine.create_beam(domain: :d, content: 'not decomposed')
      expect(engine.spectral_report[:avg_purity]).to eq(0.0)
    end

    it 'avg_purity is between 0 and 1 after decomposition' do
      id = engine.create_beam(domain: :d, content: 'will decompose')[:beam_id]
      engine.decompose(id)
      expect(engine.spectral_report[:avg_purity]).to be_between(0.0, 1.0)
    end
  end

  describe '#clear!' do
    it 'removes all beams' do
      engine.create_beam(domain: :d, content: 'a')
      engine.create_beam(domain: :d, content: 'b')
      engine.clear!
      expect(engine.beam_count).to eq(0)
    end

    it 'returns self' do
      expect(engine.clear!).to be(engine)
    end
  end

  describe '#get_beam' do
    it 'returns nil for unknown id' do
      expect(engine.get_beam('nope')).to be_nil
    end

    it 'returns the beam for a known id' do
      id = engine.create_beam(domain: :d, content: 'x')[:beam_id]
      expect(engine.get_beam(id)).to be_a(Legion::Extensions::CognitivePrism::Helpers::Beam)
    end
  end
end
