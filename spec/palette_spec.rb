require_relative 'spec_helper'
require_relative '../lib/pigment/palette'

RSpec.describe 'Pigment::Pallete' do
  let(:colors) do
    {
        red:   Pigment::Color::RGB.new(1, 0, 0),
        'green' => Pigment::Color::RGB.new(0, 1, 0),
        blue:  Pigment::Color::RGB.new(0, 0, 1),
    }
  end
  subject { Pigment::Palette.new(**colors) }
  let(:bw) do
    {
        white: Pigment::Color::RGB.new(1, 1, 1),
        black: Pigment::Color::RGB.new(0, 0, 0)
    }
  end
  let(:bw_pallete) { Pigment::Palette.new(**bw) }

  describe '::new' do
    it 'should create an empty pallete' do
      # Pigment::Pallete.new
      expect { Pigment::Palette.new }.not_to raise_error
    end

    it 'accepts hash tables' do
      expect { Pigment::Palette.new(blue: Pigment::Color::RGB.new(0, 0, 1)) }.not_to raise_error
    end
  end

  describe '#each' do
    it 'returns an enumeration without a block' do
      expect(subject.each).to be_an Enumerable
    end

    it 'returns itself if a block is passed' do
      expect(subject.each {}).to eq subject
    end

    it 'evaluates the block for ever member of the Pallete colors' do
      array = []
      expect(subject.each {|name, color| array << [name, color]}).to eq subject
      expect(array).to eq colors.to_a
    end
  end

  describe '#map' do
    it 'maps due to being enumerable' do
      expect(subject.map.to_a).to eq colors.to_a
    end
  end

  describe '#[]' do
    it 'accepts any combination of keys' do
      expect(bw_pallete[:white]).to eq bw[:white]
      expect(bw_pallete[:black, :white]).to eq [bw[:black], bw[:white]]
      expect { bw_pallete[Object.new] }.to raise_error KeyError
      expect(bw_pallete[]).to eq []
    end
  end

  describe '#[]=' do
    it 'adds colors' do
      expect(subject[:black, :dark] = bw[:black]).to eq bw[:black]
      expect(subject).to eq subject + {black: bw[:black], dark: bw[:black]}
    end
  end

  describe '#+' do
    it 'accepts another Pallete' do
      expect(subject + bw_pallete).to eq Pigment::Palette.new(**colors.merge(bw))
    end

    it 'accepts hash' do
      expect(subject + bw).to eq Pigment::Palette.new(**colors.merge(bw))
    end

    it 'does not accept any other object' do
      expect { subject + Object.new}.to raise_error ArgumentError
    end
  end

  describe '#-' do
    it 'accepts Pigment::Color' do
      subject + {vermilion: colors[:red]}
      expect(subject - colors[:red]).to eq Pigment::Palette.new(**(colors.delete_if {|_, color| color == colors[:red]}))
      expect(subject.colors).not_to include [:red, :vermilion]
    end

    it 'accepts any possible key' do
      expect(subject - Object.new).to eq nil
      expect(subject - :red).to eq colors[:red]
      colors.delete(:red)
      expect(subject.to_h).to eq colors
    end
  end

  describe '#==' do
    it 'returns true if the palletes are the same' do
      expect(subject == subject).to be true
    end

    it 'returns false if the palletes are not the same' do
      expect(bw_pallete == subject).to be false
      expect(bw_pallete == Pigment::Palette.new(red: bw[:white], blue: bw[:black]))
    end
  end

  describe '#names' do
    it 'returns a list of color names' do
      expect(subject.names).to eq [:red, 'green', :blue]
    end
  end

  describe '#colors' do
    it 'returns a list of colors' do
      expect(subject.colors).to eq colors.values
    end
  end

  describe '#method_missing' do
    it 'accepts any valid key String or Symbol key' do
      expect(subject.red).to eq colors[:red]
      expect(subject.green).to eq colors['green']
      expect(subject.blue).to eq colors[:blue]
    end

    it 'returns an error if the name is not recognized' do
      expect { subject.something }.to raise_error NoMethodError
    end
  end
end