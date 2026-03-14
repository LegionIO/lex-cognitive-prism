# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitivePrism::Client do
  subject(:client) { described_class.new }

  describe '#initialize' do
    it 'creates a client with a default engine' do
      expect(client.engine).to be_a(Legion::Extensions::CognitivePrism::Helpers::PrismEngine)
    end

    it 'accepts an injected engine' do
      custom = Legion::Extensions::CognitivePrism::Helpers::PrismEngine.new
      c = described_class.new(engine: custom)
      expect(c.engine).to be(custom)
    end

    it 'accepts extra kwargs via ** splat' do
      expect { described_class.new(extra: :param) }.not_to raise_error
    end
  end

  describe 'runner delegation' do
    let(:engine) { Legion::Extensions::CognitivePrism::Helpers::PrismEngine.new }
    subject(:client) { described_class.new(engine: engine) }

    it 'delegates create_beam to the runner' do
      result = client.create_beam(domain: :test, content: 'client test idea')
      expect(result[:success]).to be true
    end

    it 'delegates decompose to the runner' do
      id = client.create_beam(domain: :test, content: 'decompose me')[:beam_id]
      result = client.decompose(beam_id: id)
      expect(result[:success]).to be true
      expect(result[:component_count]).to eq(8)
    end

    it 'delegates recompose to the runner' do
      result = client.recompose(component_ids: [])
      expect(result[:success]).to be true
    end

    it 'delegates attenuate_all to the runner' do
      id = client.create_beam(domain: :d, content: 'attenuate me')[:beam_id]
      client.decompose(beam_id: id)
      result = client.attenuate_all
      expect(result[:success]).to be true
    end

    it 'delegates dominant_bands to the runner' do
      result = client.dominant_bands
      expect(result[:success]).to be true
    end

    it 'delegates most_intense to the runner' do
      result = client.most_intense
      expect(result[:success]).to be true
      expect(result[:components]).to be_an(Array)
    end

    it 'delegates spectral_report to the runner' do
      result = client.spectral_report
      expect(result[:success]).to be true
    end
  end

  describe 'full decompose-recompose cycle' do
    let(:engine) { Legion::Extensions::CognitivePrism::Helpers::PrismEngine.new }
    subject(:client) { described_class.new(engine: engine) }

    it 'completes a full white-light-in rainbow-out-recombine cycle' do
      idea = 'The mind arises from complexity through emergent self-organization of neural substrates'
      cr = client.create_beam(domain: :philosophy, content: idea)
      expect(cr[:success]).to be true

      dr = client.decompose(beam_id: cr[:beam_id])
      expect(dr[:success]).to be true
      expect(dr[:component_count]).to eq(8)

      beam = engine.get_beam(cr[:beam_id])
      ids  = beam.components.reject(&:faded?).map { |c| "#{cr[:beam_id]}:#{c.band}" }
      rr   = client.recompose(component_ids: ids)
      expect(rr[:success]).to be true
    end
  end
end
