# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitivePrism::Helpers::SpectralComponent do
  let(:valid_args) { { band: :green, wavelength: 520, intensity: 0.75, content: 'relational structure' } }
  subject(:component) { described_class.new(**valid_args) }

  describe '#initialize' do
    it 'creates a component with valid attributes' do
      expect(component.band).to eq(:green)
      expect(component.wavelength).to eq(520)
      expect(component.intensity).to eq(0.75)
      expect(component.content).to eq('relational structure')
    end

    it 'raises ArgumentError for unknown band' do
      expect { described_class.new(band: :gamma, wavelength: 520, intensity: 0.5, content: 'x') }
        .to raise_error(ArgumentError, /Unknown band/)
    end

    it 'raises ArgumentError when wavelength out of range for band' do
      expect { described_class.new(band: :red, wavelength: 200, intensity: 0.5, content: 'x') }
        .to raise_error(ArgumentError, /out of range/)
    end

    it 'clamps intensity above 1.0 to 1.0' do
      c = described_class.new(band: :blue, wavelength: 470, intensity: 1.5, content: 'test')
      expect(c.intensity).to eq(1.0)
    end

    it 'clamps intensity below 0.0 to 0.0' do
      c = described_class.new(band: :blue, wavelength: 470, intensity: -0.3, content: 'test')
      expect(c.intensity).to eq(0.0)
    end

    it 'accepts intensity of exactly 0.0' do
      c = described_class.new(band: :violet, wavelength: 420, intensity: 0.0, content: 'x')
      expect(c.intensity).to eq(0.0)
    end

    it 'accepts intensity of exactly 1.0' do
      c = described_class.new(band: :red, wavelength: 650, intensity: 1.0, content: 'x')
      expect(c.intensity).to eq(1.0)
    end
  end

  describe '#attenuate!' do
    it 'reduces intensity by the default rate' do
      original = component.intensity
      component.attenuate!
      expect(component.intensity).to be < original
    end

    it 'reduces intensity by the specified rate' do
      component.attenuate!(rate: 0.3)
      expect(component.intensity).to be_within(0.001).of(0.45)
    end

    it 'clamps intensity at 0.0' do
      component.attenuate!(rate: 2.0)
      expect(component.intensity).to eq(0.0)
    end

    it 'returns self for chaining' do
      expect(component.attenuate!).to be(component)
    end

    it 'takes absolute value of rate (negative rate still attenuates)' do
      original = component.intensity
      component.attenuate!(rate: -0.1)
      expect(component.intensity).to be < original
    end
  end

  describe '#amplify!' do
    let(:low_component) { described_class.new(band: :green, wavelength: 520, intensity: 0.3, content: 'low') }

    it 'increases intensity by the default boost' do
      original = low_component.intensity
      low_component.amplify!
      expect(low_component.intensity).to be > original
    end

    it 'increases intensity by specified boost' do
      low_component.amplify!(boost: 0.4)
      expect(low_component.intensity).to be_within(0.001).of(0.7)
    end

    it 'clamps intensity at 1.0' do
      low_component.amplify!(boost: 5.0)
      expect(low_component.intensity).to eq(1.0)
    end

    it 'returns self for chaining' do
      expect(low_component.amplify!).to be(low_component)
    end
  end

  describe '#dominant?' do
    it 'returns true when intensity >= 0.7' do
      c = described_class.new(band: :blue, wavelength: 470, intensity: 0.8, content: 'x')
      expect(c.dominant?).to be true
    end

    it 'returns true at exactly 0.7' do
      c = described_class.new(band: :blue, wavelength: 470, intensity: 0.7, content: 'x')
      expect(c.dominant?).to be true
    end

    it 'returns false when intensity < 0.7' do
      c = described_class.new(band: :blue, wavelength: 470, intensity: 0.69, content: 'x')
      expect(c.dominant?).to be false
    end
  end

  describe '#faded?' do
    it 'returns true when intensity <= 0.1' do
      c = described_class.new(band: :orange, wavelength: 600, intensity: 0.05, content: 'x')
      expect(c.faded?).to be true
    end

    it 'returns true at exactly 0.1' do
      c = described_class.new(band: :orange, wavelength: 600, intensity: 0.1, content: 'x')
      expect(c.faded?).to be true
    end

    it 'returns false when intensity > 0.1' do
      c = described_class.new(band: :orange, wavelength: 600, intensity: 0.11, content: 'x')
      expect(c.faded?).to be false
    end
  end

  describe '#intensity_label' do
    it 'returns :trace for intensity 0.05' do
      c = described_class.new(band: :green, wavelength: 520, intensity: 0.05, content: 'x')
      expect(c.intensity_label).to eq(:trace)
    end

    it 'returns :brilliant for intensity 0.9' do
      c = described_class.new(band: :green, wavelength: 520, intensity: 0.9, content: 'x')
      expect(c.intensity_label).to eq(:brilliant)
    end

    it 'returns :strong for intensity 0.65' do
      c = described_class.new(band: :green, wavelength: 520, intensity: 0.65, content: 'x')
      expect(c.intensity_label).to eq(:strong)
    end
  end

  describe '#to_h' do
    it 'returns a hash with all expected keys' do
      h = component.to_h
      expect(h.keys).to contain_exactly(:band, :wavelength, :intensity, :intensity_label, :content, :dominant, :faded)
    end

    it 'includes correct band' do
      expect(component.to_h[:band]).to eq(:green)
    end

    it 'includes dominant flag' do
      expect(component.to_h[:dominant]).to be(component.dominant?)
    end

    it 'includes faded flag' do
      expect(component.to_h[:faded]).to be(component.faded?)
    end

    it 'includes intensity rounded to 10 decimal places' do
      expect(component.to_h[:intensity]).to eq(0.75)
    end
  end
end
