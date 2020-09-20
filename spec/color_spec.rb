require_relative 'spec_helper'
require_relative '../lib/pigment/color'

RSpec.describe 'Pigment::Color' do
  let(:hsl_black)   { Pigment::Color::HSL.new(0, 0, 0) }
  let(:hsl_white)   { Pigment::Color::HSL.new(0, 0, 1) }
  let(:hsl_red)     { Pigment::Color::HSL.new(0, 1, 0.5) }
  let(:hsl_green)   { Pigment::Color::HSL.new(1 / 3.0, 1, 0.5) }
  let(:hsl_blue)    { Pigment::Color::HSL.new(2 / 3.0, 1, 0.5) }
  let(:rgb_black)   { Pigment::Color::RGB.new(0, 0, 0, 1) }
  let(:rgb_white)   { Pigment::Color::RGB.new(1, 1, 1, 1) }
  let(:rgb_red)     { Pigment::Color::RGB.new(1, 0, 0) }
  let(:rgb_green)   { Pigment::Color::RGB.new(0, 1, 0) }
  let(:rgb_blue)    { Pigment::Color::RGB.new(0, 0, 1) }
  let(:rgb_cyan)    { Pigment::Color::RGB.new(0, 1, 1) }

  describe '::rgba' do
    it 'creates an rgba color' do
      expect(Pigment::Color.rgba(0.0, 0.0, 0.0, 1.0)).to eq rgb_black
      expect(Pigment::Color.rgba(1.0, 0.0, 0.0, 1.0)).to eq rgb_red
      expect(Pigment::Color.rgba(0.0, 1.0, 0.0, 1.0)).to eq rgb_green
      expect(Pigment::Color.rgba(0.0, 0.0, 1.0, 1.0)).to eq rgb_blue
      expect(Pigment::Color.rgba(1.0, 1.0, 1.0, 1.0)).to eq rgb_white
    end
  end

  describe '::hsla' do
    it 'creates an hsla color' do
      expect(Pigment::Color.hsla(0, 0, 0)).to eq hsl_black
      expect(Pigment::Color.hsla(0, 0, 1)).to eq hsl_white
      expect(Pigment::Color.hsla(0, 1, 0.5)).to eq hsl_red
      expect(Pigment::Color.hsla(120, 1, 0.5)).to eq hsl_green
      expect(Pigment::Color.hsla(240, 1, 0.5)).to eq hsl_blue
    end
  end

  describe '#inverse' do
    it 'inverts the color' do
      expect(rgb_red.inverse).to eq rgb_cyan
      expect(hsl_red.inverse).to eq rgb_cyan
      expect(rgb_cyan.inverse).to eq rgb_red
      expect(rgb_black.inverse).to eq rgb_white
      expect(rgb_white.inverse).to eq rgb_black
      expect(hsl_black.inverse).to eq rgb_white
      expect(hsl_white.inverse).to eq rgb_black
      expect(rgb_black.inverse).to eq hsl_white
      expect(rgb_white.inverse).to eq hsl_black
      expect(hsl_black.inverse).to eq hsl_white
      expect(hsl_white.inverse).to eq hsl_black
    end
  end

  describe '#inverse?' do
    it 'returns true if it is inverse from other color' do
      expect(rgb_red.inverse?(rgb_cyan)).to be true
      expect(rgb_cyan.inverse?(rgb_red)).to be true
      expect(rgb_black.inverse?(rgb_white)).to be true
      expect(rgb_white.inverse?(rgb_black)).to be true
      expect(hsl_black.inverse?(rgb_white)).to be true
      expect(hsl_white.inverse?(rgb_black)).to be true
      expect(rgb_black.inverse?(hsl_white)).to be true
      expect(rgb_white.inverse?(hsl_black)).to be true
      expect(hsl_black.inverse?(hsl_white)).to be true
      expect(hsl_white.inverse?(hsl_black)).to be true
    end

    it 'returns false if it is not inverse from other color or not a color' do
      expect(rgb_blue.inverse?(rgb_red)).to be false
      expect(rgb_blue.inverse?(Object.new)).to be false
    end
  end

  describe '#triadic_of?' do
    it 'returns true if a color has a triadic relationship with the given color' do
      expect(rgb_red.triadic_of?(rgb_blue)).to be true
      expect(rgb_red.triadic_of?(rgb_green)).to be true
      expect(rgb_green.triadic_of?(rgb_red)).to be true
      expect(rgb_green.triadic_of?(rgb_blue)).to be true
      expect(rgb_blue.triadic_of?(rgb_red)).to be true
      expect(rgb_blue.triadic_of?(rgb_green)).to be true

      expect(hsl_red.triadic_of?(hsl_blue)).to be true
      expect(hsl_red.triadic_of?(hsl_green)).to be true
      expect(hsl_green.triadic_of?(hsl_red)).to be true
      expect(hsl_blue.triadic_of?(hsl_red)).to be true
      expect(hsl_green.triadic_of?(hsl_blue)).to be true
      expect(hsl_green.triadic_of?(hsl_red)).to be true

      expect(rgb_red.triadic_of?(hsl_blue)).to be true
      expect(rgb_red.triadic_of?(hsl_green)).to be true
      expect(rgb_green.triadic_of?(hsl_red)).to be true
      expect(rgb_green.triadic_of?(hsl_blue)).to be true
      expect(rgb_blue.triadic_of?(hsl_red)).to be true
      expect(rgb_blue.triadic_of?(hsl_green)).to be true

      expect(hsl_red.triadic_of?(rgb_blue)).to be true
      expect(hsl_red.triadic_of?(rgb_green)).to be true
      expect(hsl_green.triadic_of?(rgb_red)).to be true
      expect(hsl_blue.triadic_of?(rgb_red)).to be true
      expect(hsl_green.triadic_of?(rgb_blue)).to be true
      expect(hsl_green.triadic_of?(rgb_red)).to be true
    end

    it 'returns false if a color does not have a triadic relationship with the given color' do
      expect(rgb_red.triadic_of?(rgb_black)).to be false
      expect(rgb_green.triadic_of?(rgb_black)).to be false
      expect(rgb_blue.triadic_of?(rgb_black)).to be false
      expect(rgb_black.triadic_of?(rgb_green)).to be false
      expect(rgb_black.triadic_of?(rgb_blue)).to be false
      expect(rgb_black.triadic_of?(rgb_red)).to be false

      expect(hsl_red.triadic_of?(rgb_black)).to be false
      expect(hsl_green.triadic_of?(rgb_black)).to be false
      expect(hsl_blue.triadic_of?(rgb_black)).to be false
      expect(hsl_black.triadic_of?(rgb_green)).to be false
      expect(hsl_black.triadic_of?(rgb_blue)).to be false
      expect(hsl_black.triadic_of?(rgb_red)).to be false

      expect(rgb_red.triadic_of?(hsl_black)).to be false
      expect(rgb_green.triadic_of?(hsl_black)).to be false
      expect(rgb_blue.triadic_of?(hsl_black)).to be false
      expect(rgb_black.triadic_of?(hsl_green)).to be false
      expect(rgb_black.triadic_of?(hsl_blue)).to be false
      expect(rgb_black.triadic_of?(hsl_red)).to be false
    end
  end

  describe '#triadic_include?' do
    it 'returns true' do
      expect(rgb_red.triadic_include?(rgb_blue, rgb_green)).to eq true
      expect(rgb_green.triadic_include?(rgb_blue, rgb_red)).to eq true
      expect(rgb_blue.triadic_include?(rgb_red, rgb_green)).to eq true

      expect(rgb_red.triadic_include?(hsl_blue, rgb_green)).to eq true
      expect(rgb_green.triadic_include?(hsl_blue, rgb_red)).to eq true
      expect(rgb_blue.triadic_include?(hsl_red, rgb_green)).to eq true

      expect(rgb_red.triadic_include?(hsl_blue, hsl_green)).to eq true
      expect(rgb_green.triadic_include?(hsl_blue, hsl_red)).to eq true
      expect(rgb_blue.triadic_include?(hsl_red, hsl_green)).to eq true

      expect(hsl_red.triadic_include?(rgb_blue, rgb_green)).to eq true
      expect(hsl_green.triadic_include?(rgb_blue, rgb_red)).to eq true
      expect(hsl_blue.triadic_include?(rgb_red, rgb_green)).to eq true

      expect(hsl_red.triadic_include?(hsl_blue, rgb_green)).to eq true
      expect(hsl_green.triadic_include?(hsl_blue, rgb_red)).to eq true
      expect(hsl_blue.triadic_include?(hsl_red, rgb_green)).to eq true

      expect(hsl_red.triadic_include?(hsl_blue, hsl_green)).to eq true
      expect(hsl_green.triadic_include?(hsl_blue, hsl_red)).to eq true
      expect(hsl_blue.triadic_include?(hsl_red, hsl_green)).to eq true
    end

    it 'returns false' do
      expect(rgb_red.triadic_include?(rgb_blue, rgb_green)).to eq true
      expect(rgb_green.triadic_include?(rgb_blue, rgb_red)).to eq true
      expect(rgb_blue.triadic_include?(rgb_red, rgb_green)).to eq true

      expect(hsl_red.triadic_include?(hsl_blue, hsl_green)).to eq true
      expect(hsl_green.triadic_include?(hsl_blue, hsl_red)).to eq true
      expect(hsl_blue.triadic_include?(hsl_red, hsl_green)).to eq true
    end
  end

  let(:split_from_red) {
    [
        Pigment::Color::HSL.new(-5 / 12.0, 1.0, 0.5),
        Pigment::Color::HSL.new(5 / 12.0, 1.0, 0.5)]
  }

  describe '#split' do
    it 'returns the split colors from self' do
      expect(rgb_red.split).to eq split_from_red
    end
  end

  describe '#split_of?' do
    it 'returns true if a color has a split relationship with the given color' do
      expect(split_from_red.all? {|color| color.split_of?(rgb_red)}).to be true
      expect(split_from_red.all? {|color| color.split_of?(hsl_red)}).to be true
    end

    it 'returns false if a color does not have a split relationship with the given color' do
      expect(split_from_red.any? {|color| color.split_of?(rgb_blue)}).to be false
      expect(split_from_red.any? {|color| color.split_of?(hsl_blue)}).to be false
    end

  end

  describe '#split_include?' do
    it 'returns true' do
      expect(rgb_red.split_include?(*split_from_red)).to be true
      expect(hsl_red.split_include?(*split_from_red)).to be true
    end

    it 'returns false' do
      expect(rgb_red.split_include?(rgb_black, rgb_blue)).to be false
      expect(hsl_red.split_include?(rgb_black, rgb_blue)).to be false
    end
  end

  let(:analogous_from_red) {
    [
        Pigment::Color::HSL.new(-1 / 12.0, 1.0, 0.5),
        Pigment::Color::HSL.new(1 / 12.0, 1.0, 0.5)
    ]
  }

  describe '#analogous' do
    it 'returns the split colors from self' do
      expect(rgb_red.analogous).to eq analogous_from_red
    end
  end

  describe '#analogous_of?' do
    it 'returns true if a color has a analogous relationship with the given color' do
      expect(analogous_from_red.all? {|color| color.analogous_of?(rgb_red)}).to be true
      expect(analogous_from_red.all? {|color| color.analogous_of?(hsl_red)}).to be true
    end

    it 'returns false if a color does not have a analogous relationship with the given color' do
      expect(analogous_from_red.any? {|color| color.analogous_of?(rgb_blue)}).to be false
      expect(analogous_from_red.any? {|color| color.analogous_of?(hsl_blue)}).to be false
    end
  end

  describe '#analogous_include?' do
    it 'returns true' do
      expect(rgb_red.analogous_include?(*analogous_from_red)).to be true
      expect(hsl_red.analogous_include?(*analogous_from_red)).to be true
    end

    it 'returns false' do
      expect(rgb_red.analogous_include?(rgb_black, rgb_blue)).to be false
      expect(hsl_red.analogous_include?(rgb_black, rgb_blue)).to be false
    end
  end

  let(:tetradic_from_red) {
    [
        Pigment::Color::HSL.new(1 / 4.0, 1.0, 0.5),
        Pigment::Color::HSL.new(1 / 2.0, 1.0, 0.5),
        Pigment::Color::HSL.new(3 / 4.0, 1.0, 0.5)
    ]
  }

  describe '#tetradic' do
    it 'returns the split colors from self' do
      expect(rgb_red.tetradic).to eq tetradic_from_red
    end
  end

  describe '#tetradic_of?' do
    it 'returns true if a color has a tetradic relationship with the given color' do
      expect(tetradic_from_red.all? {|color| color.tetradic_of?(rgb_red)}).to be true
      expect(tetradic_from_red.all? {|color| color.tetradic_of?(hsl_red)}).to be true
    end

    it 'returns false if a color does not have a tetradic relationship with the given color' do
      expect(tetradic_from_red.any? {|color| color.tetradic_of?(rgb_blue)}).to be false
      expect(tetradic_from_red.any? {|color| color.tetradic_of?(hsl_blue)}).to be false
    end
  end

  describe '#tetradic_include?' do
    it 'returns true' do
      expect(rgb_red.tetradic_include?(*tetradic_from_red)).to be true
      expect(hsl_red.tetradic_include?(*tetradic_from_red)).to be true
    end

    it 'returns false' do
      expect(rgb_red.tetradic_include?(rgb_black, rgb_blue)).to be false
      expect(hsl_red.tetradic_include?(rgb_black, rgb_blue)).to be false
    end
  end

  let(:rectangular_from_red) {
    [
        Pigment::Color::HSL.new(1 / 6.0, 1.0, 0.5),
        Pigment::Color::HSL.new(1 / 2.0, 1.0, 0.5),
        Pigment::Color::HSL.new(2 / 3.0, 1.0, 0.5)
    ]
  }

  describe '#rectangular' do
    it 'returns the rectangular colors from self' do
      expect(rgb_red.rectangular).to eq rectangular_from_red
    end
  end

  describe '#rectangular_of?' do
    it 'returns true if a color has a rectangular relationship with the given color' do
      expect(rectangular_from_red.all? { |color| color.rectangular_of?(rgb_red) } ).to be true
      expect(rectangular_from_red.all? { |color| color.rectangular_of?(hsl_red) } ).to be true
    end

    it 'returns false if a color does not have a rectangular relationship with the given color' do
      expect(rectangular_from_red.any? { |color| color.rectangular_of?(rgb_white) } ).to be false
      expect(rectangular_from_red.any? { |color| color.rectangular_of?(rgb_white) } ).to be false
    end
  end

  describe '#rectangular_include?' do
    it 'returns true' do
      puts rectangular_from_red
      puts rgb_red.rectangular.map { |color| color.into(Pigment::Color::HSL)}
      expect(rgb_red.rectangular_include?(*rectangular_from_red)).to be true
      expect(hsl_red.rectangular_include?(*rectangular_from_red)).to be true
    end

    it 'returns false' do
      expect(rgb_red.rectangular_include?(rgb_black, rgb_blue)).to be false
      expect(hsl_red.rectangular_include?(rgb_black, rgb_blue)).to be false
    end
  end

  let(:tertiary_from_red) {
    [
        Pigment::Color::RGB.new(1, 1, 0),
        rgb_green,
        Pigment::Color::RGB.new(0, 1, 1),
        rgb_blue,
        Pigment::Color::RGB.new(1, 0, 1),
    ]
  }

  describe '#tertiary' do
    it 'returns the split colors from self' do
      expect(rgb_red.tertiary).to eq tertiary_from_red
    end
  end


  describe '#tertiary_of?' do
    it 'returns true if a color has a tertiary relationship with the given color' do
      expect(tertiary_from_red.all? { |color| color.tertiary_of?(rgb_red) } ).to be true
      expect(tertiary_from_red.all? { |color| color.tertiary_of?(hsl_red) } ).to be true
    end

    it 'returns false if a color does not have a tertiary relationship with the given color' do
      expect(tertiary_from_red.any? { |color| color.tertiary_of?(rgb_white) } ).to be false
      expect(tertiary_from_red.any? { |color| color.tertiary_of?(rgb_white) } ).to be false
    end
  end

  describe '#tertiary_include?' do
    it 'returns true' do
      expect(rgb_red.tertiary_include?(*tertiary_from_red)).to be true
      expect(hsl_red.tertiary_include?(*tertiary_from_red)).to be true
    end

    it 'returns false' do
      expect(rgb_red.tertiary_include?(rgb_black, rgb_blue)).to be false
      expect(hsl_red.tertiary_include?(rgb_black, rgb_blue)).to be false
    end
  end

  describe '#to_html' do
    it 'converts a color to html format' do
      expect(rgb_black.to_html).to eq '#000000'
      expect(rgb_red.to_html).to eq '#ff0000'
      expect(rgb_green.to_html).to eq '#00ff00'
      expect(rgb_blue.to_html).to eq '#0000ff'
      expect(rgb_white.to_html).to eq '#ffffff'
      expect(hsl_black.to_html).to eq '#000000'
      expect(hsl_red.to_html).to eq '#ff0000'
      expect(hsl_green.to_html).to eq '#00ff00'
      expect(hsl_blue.to_html).to eq '#0000ff'
      expect(hsl_white.to_html).to eq '#ffffff'
    end

    it 'adds alpha channel' do
      expect(rgb_black.to_html(with_alpha: true)).to eq '#000000ff'
      expect(rgb_red.to_html(with_alpha: true)).to eq '#ff0000ff'
      expect(rgb_green.to_html(with_alpha: true)).to eq '#00ff00ff'
      expect(rgb_blue.to_html(with_alpha: true)).to eq '#0000ffff'
      expect(rgb_white.to_html(with_alpha: true)).to eq '#ffffffff'
      expect(hsl_black.to_html(with_alpha: true)).to eq '#000000ff'
      expect(hsl_red.to_html(with_alpha: true)).to eq '#ff0000ff'
      expect(hsl_green.to_html(with_alpha: true)).to eq '#00ff00ff'
      expect(hsl_blue.to_html(with_alpha: true)).to eq '#0000ffff'
      expect(hsl_white.to_html(with_alpha: true)).to eq '#ffffffff'
    end
  end

  describe '#to_hex' do
    it 'converts a color to hex format' do
      expect(rgb_black.to_hex(with_alpha: false)).to eq '000000'
      expect(rgb_red.to_hex(with_alpha: false)).to eq 'ff0000'
      expect(rgb_green.to_hex(with_alpha: false)).to eq '00ff00'
      expect(rgb_blue.to_hex(with_alpha: false)).to eq '0000ff'
      expect(rgb_white.to_hex(with_alpha: false)).to eq 'ffffff'
      expect(hsl_black.to_hex(with_alpha: false)).to eq '000000'
      expect(hsl_red.to_hex(with_alpha: false)).to eq 'ff0000'
      expect(hsl_green.to_hex(with_alpha: false)).to eq '00ff00'
      expect(hsl_blue.to_hex(with_alpha: false)).to eq '0000ff'
      expect(hsl_white.to_hex(with_alpha: false)).to eq 'ffffff'
    end

    it 'removes alpha channel' do
      expect(rgb_black.to_hex).to eq '000000ff'
      expect(rgb_red.to_hex).to eq 'ff0000ff'
      expect(rgb_green.to_hex).to eq '00ff00ff'
      expect(rgb_blue.to_hex).to eq '0000ffff'
      expect(rgb_white.to_hex).to eq 'ffffffff'
      expect(hsl_black.to_hex).to eq '000000ff'
      expect(hsl_red.to_hex).to eq 'ff0000ff'
      expect(hsl_green.to_hex).to eq '00ff00ff'
      expect(hsl_blue.to_hex).to eq '0000ffff'
      expect(hsl_white.to_hex).to eq 'ffffffff'
    end
  end

  describe 'to_ints' do
    it 'converts to an array of integers' do
      expect(rgb_black.to_ints).to eq [0, 0, 0, 255]
      expect(rgb_red.to_ints).to eq [255, 0, 0, 255]
      expect(rgb_green.to_ints).to eq [0, 255, 0, 255]
      expect(rgb_blue.to_ints).to eq [0, 0, 255, 255]
      expect(rgb_white.to_ints).to eq [255, 255, 255, 255]
      expect(hsl_black.to_ints).to eq [0, 0, 0, 255]
      expect(hsl_red.to_ints).to eq [255, 0, 0, 255]
      expect(hsl_green.to_ints).to eq [0, 255, 0, 255]
      expect(hsl_blue.to_ints).to eq [0, 0, 255, 255]
      expect(hsl_white.to_ints).to eq [255, 255, 255, 255]
    end

    it 'converts to an array of integers without alpha' do
      expect(rgb_black.to_ints(with_alpha: false)).to eq [0, 0, 0]
      expect(rgb_red.to_ints(with_alpha: false)).to eq [255, 0, 0]
      expect(rgb_green.to_ints(with_alpha: false)).to eq [0, 255, 0]
      expect(rgb_blue.to_ints(with_alpha: false)).to eq [0, 0, 255]
      expect(rgb_white.to_ints(with_alpha: false)).to eq [255, 255, 255]
      expect(hsl_black.to_ints(with_alpha: false)).to eq [0, 0, 0]
      expect(hsl_red.to_ints(with_alpha: false)).to eq [255, 0, 0]
      expect(hsl_green.to_ints(with_alpha: false)).to eq [0, 255, 0]
      expect(hsl_blue.to_ints(with_alpha: false)).to eq [0, 0, 255]
      expect(hsl_white.to_ints(with_alpha: false)).to eq [255, 255, 255]
    end
  end
end
