require_relative '../spec_helper'
require_relative '../../lib/pigment/color/hsl'

RSpec.describe 'Pigment::Color::HSL' do
  let(:hsl_black)   { Pigment::Color::HSL.new(0, 0, 0) }
  let(:hsl_white)   { Pigment::Color::HSL.new(0, 0, 1) }
  let(:inverse_red) { Pigment::Color::HSL.new(0.5, 1, 0.5) }
  let(:hsl_red)     { Pigment::Color::HSL.new(0, 1, 0.5) }
  let(:hsl_green)   { Pigment::Color::HSL.new(1 / 3.0, 1, 0.5) }
  let(:hsl_blue)    { Pigment::Color::HSL.new(2 / 3.0, 1, 0.5) }
  let(:rgb_black)   { Pigment::Color::RGB.new(0, 0, 0, 1) }
  let(:rgb_white)   { Pigment::Color::RGB.new(1, 1, 1, 1) }
  let(:rgb_red)     { Pigment::Color::RGB.new(1, 0, 0) }
  let(:rgb_green)   { Pigment::Color::RGB.new(0, 1, 0) }
  let(:rgb_blue)    { Pigment::Color::RGB.new(0, 0, 1) }

  describe '::convert' do
    it 'converts a rgb color to a hsl color' do
      expect(Pigment::Color::HSL.convert(rgb_black)).to eq hsl_black
      expect(Pigment::Color::HSL.convert(hsl_black)).to eq hsl_black
      expect(Pigment::Color::HSL.convert(rgb_white)).to eq hsl_white
      expect(Pigment::Color::HSL.convert(hsl_white)).to eq hsl_white
      expect(Pigment::Color::HSL.convert(rgb_red)).to eq hsl_red
      expect(Pigment::Color::HSL.convert(hsl_red)).to eq hsl_red
      expect(Pigment::Color::HSL.convert(rgb_green)).to eq hsl_green
      expect(Pigment::Color::HSL.convert(hsl_green)).to eq hsl_green
      expect(Pigment::Color::HSL.convert(rgb_blue)).to eq hsl_blue
      expect(Pigment::Color::HSL.convert(hsl_blue)).to eq hsl_blue
    end

    it 'raises an error if the color is not an Pigment::Color' do
      expect { Pigment::Color::HSL.convert(Object.new) }.to raise_error NoMethodError
    end
  end

  describe '::from_hue_angle' do
    it 'acceps a hue from 0 to 360' do
      expect(Pigment::Color::HSL.from_hue_angle(0, 1, 0.5)).to eq hsl_red
      expect(Pigment::Color::HSL.from_hue_angle(120, 1, 0.5)).to eq hsl_green
      expect(Pigment::Color::HSL.from_hue_angle(240, 1, 0.5)).to eq hsl_blue
      expect(Pigment::Color::HSL.from_hue_angle(360, 1, 0.5)).to eq hsl_red
    end
  end

  describe '::new' do
    it 'Accepts Integers and Floats' do
      expect(Pigment::Color::HSL.new(0, 1, 0.5)).to eq hsl_red
      expect(Pigment::Color::HSL.new(1 / 3.0, 1, 0.5)).to eq hsl_green
      expect(Pigment::Color::HSL.new(2 / 3.0, 1, 0.5)).to eq hsl_blue
    end

    it 'Does not accept Objects other than Integers or Floats' do
      expect { Pigment::Color::HSL.new(Object.new, 1, 0.5) }.to raise_error NoMethodError
    end

    it 'Accepts alpha value' do
      expect(Pigment::Color::HSL.new(0, 1, 0.5, 1)).to eq hsl_red
    end
  end

  describe '#into' do
    it 'converts a color to RGB format' do
      expect(hsl_red.into(Pigment::Color::RGB)).to eq rgb_red
      expect(hsl_green.into(Pigment::Color::RGB)).to eq rgb_green
      expect(hsl_blue.into(Pigment::Color::RGB)).to eq rgb_blue
      expect(hsl_black.into(Pigment::Color::RGB)).to eq rgb_black
      expect(hsl_white.into(Pigment::Color::RGB)).to eq rgb_white
    end
  end

  describe '#dup' do
    it 'clones a color' do
      expect(hsl_red.dup).to eq hsl_red
    end
  end

  describe '#inverse' do
    it 'returns the inverse color' do
      expect(hsl_black.inverse).to eq hsl_white
      expect(hsl_white.inverse).to eq hsl_black
      expect(hsl_red.inverse).to eq inverse_red
    end
  end

  describe '#inverse?' do
    it 'is true when the color supplied is inverse' do
      expect(hsl_white.inverse?(hsl_black)).to be true
      expect(hsl_black.inverse?(hsl_white)).to be true
      expect(inverse_red.inverse?(hsl_red)).to be true
      expect(hsl_red.inverse?(inverse_red)).to be true
    end
  end

  describe 'triadic' do
    it 'creates 2 triadic colors' do
      expect(hsl_red.triadic).to eq [hsl_green, hsl_blue]
      expect(hsl_green.triadic).to eq [hsl_blue, hsl_red]
      expect(hsl_blue.triadic).to eq [hsl_red, hsl_green]
    end
  end

  describe '#triadic_of?' do
    it 'returns true if self is a triadic of the given color' do
      expect(hsl_red.triadic_of?(hsl_blue)).to be true
      expect(hsl_red.triadic_of?(hsl_green)).to be true
      expect(hsl_green.triadic_of?(hsl_red)).to be true
      expect(hsl_blue.triadic_of?(hsl_red)).to be true
      expect(hsl_green.triadic_of?(hsl_blue)).to be true
      expect(hsl_green.triadic_of?(hsl_red)).to be true
    end

    it 'returns false if self is not a triadic of a given color' do
      expect(hsl_red.triadic_of?(hsl_red)).to be false
    end
  end

  describe 'triadic_include?' do
    it 'returns true' do
      expect(hsl_red.triadic_include?(hsl_blue, hsl_green)).to eq true
      expect(hsl_green.triadic_include?(hsl_blue, hsl_red)).to eq true
      expect(hsl_blue.triadic_include?(hsl_red, hsl_green)).to eq true
    end

    it 'returns false' do
      expect(hsl_red.triadic_include?(hsl_blue, hsl_green)).to eq true
      expect(hsl_green.triadic_include?(hsl_blue, hsl_red)).to eq true
      expect(hsl_blue.triadic_include?(hsl_red, hsl_green)).to eq true
    end
  end

  describe '#split' do
    it 'returns the split colors from self' do
      split_from_red = [Pigment::Color::HSL.new(-5 / 12.0, 1.0, 0.5), Pigment::Color::HSL.new(5 / 12.0, 1.0, 0.5)]
      expect(hsl_red.split).to eq split_from_red
    end
  end

  describe '#analogous' do
    it 'returns the split colors from self' do
      analogous_from_red = [Pigment::Color::HSL.new(-1 / 12.0, 1.0, 0.5), Pigment::Color::HSL.new(1 / 12.0, 1.0, 0.5)]
      expect(hsl_red.analogous).to eq analogous_from_red
    end
  end

  describe '#tetradic' do
    it 'returns the split colors from self' do
      tetadric_from_red = [
          Pigment::Color::HSL.new(1 / 4.0, 1.0, 0.5),
          Pigment::Color::HSL.new(1 / 2.0, 1.0, 0.5),
          Pigment::Color::HSL.new(3 / 4.0, 1.0, 0.5)
      ]
      expect(hsl_red.tetradic).to eq tetadric_from_red
    end
  end

  describe '#rectangular' do
    it 'returns the split colors from self' do
      rectangular_from_red = [
          Pigment::Color::HSL.new(1 / 6.0, 1.0, 0.5),
          Pigment::Color::HSL.new(1 / 2.0, 1.0, 0.5),
          Pigment::Color::HSL.new(2 / 3.0, 1.0, 0.5)
      ]
      expect(hsl_red.rectangular).to eq rectangular_from_red
    end
  end

  describe '#tertiary' do
    it 'returns the split colors from self' do
      tertiary_from_red = [
          Pigment::Color::RGB.new(1, 1, 0),
          rgb_green,
          Pigment::Color::RGB.new(0, 1, 1),
          rgb_blue,
          Pigment::Color::RGB.new(1, 0, 1),
      ].map { |color| color.into(Pigment::Color::HSL) }
      expect(hsl_red.tertiary).to eq tertiary_from_red
    end
  end

  describe '#grayscale' do
    it 'returns a grayscale version of the color' do
      expect(hsl_red.grayscale).to be_gray
      expect(hsl_green.grayscale).to be_gray
      expect(hsl_blue.grayscale).to be_gray
    end
  end


  describe '#grayscale?' do
    it 'returns true if it is grayscale color' do
      expect(hsl_white).to be_grayscale
      expect(hsl_black).to be_grayscale
      expect(Pigment::Color::HSL.new(0, 0, 0)).to be_grayscale
    end

    it 'returns true if it is grayscale color' do
      expect(hsl_red).not_to be_grayscale
      expect(hsl_green).not_to be_grayscale
      expect(hsl_blue).not_to be_grayscale
      expect(Pigment::Color::HSL.new(0, 0.5, 0)).not_to be_grayscale
    end
  end

  describe '#to_s' do
    it 'returns a string representation' do
      expect(hsl_white.to_s).to eq 'HSL Color(hue: 0.0, saturation: 0.0, lightness: 1.0, alpha: 1.0)'
      expect(hsl_black.to_s).to eq 'HSL Color(hue: 0.0, saturation: 0.0, lightness: 0.0, alpha: 1.0)'
      expect(hsl_red.to_s).to eq 'HSL Color(hue: 0.0, saturation: 1.0, lightness: 0.5, alpha: 1.0)'
      expect(hsl_green.to_s).to eq "HSL Color(hue: #{1 / 3.0}, saturation: 1.0, lightness: 0.5, alpha: 1.0)"
      expect(hsl_blue.to_s).to eq "HSL Color(hue: #{2 / 3.0}, saturation: 1.0, lightness: 0.5, alpha: 1.0)"
      expect(inverse_red.to_s).to eq 'HSL Color(hue: 0.5, saturation: 1.0, lightness: 0.5, alpha: 1.0)'
    end
  end

  describe '#method_missing' do
    it 'swizzles the color' do
      expect(hsl_red.hhhh).to eq [0.0, 0.0, 0.0, 0.0]
    end

    it 'returns an error if the method is not recognized' do
      expect { hsl_red.something }.to raise_error NoMethodError
    end
  end
end