require_relative '../spec_helper'
require_relative '../../lib/pigment/color/rgb'

RSpec.describe 'Pigment::Color::RGB' do
  let(:rgb_black) { Pigment::Color::RGB.new(0, 0, 0, 1) }
  let(:rgb_white) { Pigment::Color::RGB.new(1, 1, 1, 1) }
  let(:rgb_cyan)  { Pigment::Color::RGB.new(0, 1, 1, 1) }
  let(:rgb_red)   { Pigment::Color::RGB.new(1, 0, 0, 1) }
  let(:rgb_green) { Pigment::Color::RGB.new(0, 1, 0, 1) }
  let(:rgb_blue)  { Pigment::Color::RGB.new(0, 0, 1, 1) }
  let(:hsl_black) { Pigment::Color::HSL.new(0, 0, 0, 1)}
  let(:hsl_white) { Pigment::Color::HSL.new(0, 0, 1, 1)}
  let(:hsl_red)   { Pigment::Color::HSL.new(0, 1, 0.5) }
  let(:hsl_green) { Pigment::Color::HSL.new(1 / 3.0, 1, 0.5) }
  let(:hsl_blue)  { Pigment::Color::HSL.new(2 / 3.0, 1, 0.5) }
  let(:rgb_yellow){ Pigment::Color::RGB.new(1, 1, 0, 1) }

  describe '::convert' do
    it 'converts into Pigment::Color::RGB color' do
      expect(Pigment::Color::RGB.convert(hsl_black)).to eq rgb_black
      expect(Pigment::Color::RGB.convert(hsl_white)).to eq rgb_white
      expect(Pigment::Color::RGB.convert(hsl_red)).to eq rgb_red
      expect(Pigment::Color::RGB.convert(hsl_green)).to eq rgb_green
      expect(Pigment::Color::RGB.convert(hsl_blue)).to eq rgb_blue
    end

    it 'raises Invalid Format error' do
      expect { Pigment::Color::RGB.convert(Object.new) }.to raise_error Pigment::Color::InvalidColorFormatError
    end
  end

  describe '::from_hex' do

    it 'creates a color from an hexadecimal number' do
      expect(Pigment::Color::RGB.from_hex('ffffffff')).to eq rgb_white
    end

    it 'defaults alpha to 1' do
      expect(Pigment::Color::RGB.from_hex('ffffff')).to eq rgb_white
    end

    it 'Accepts Integers' do
      expect(Pigment::Color::RGB.from_hex(0xffffffff)).to eq rgb_white
    end

    it 'Accepts Floats' do
      expect(Pigment::Color::RGB.from_hex(0xffffffff.to_f)).to eq rgb_white
    end

    it 'raises Invalid hex color format Pigment::Color::InvalidColorFormatError with invalid String' do
      expect { Pigment::Color::RGB.from_hex('hhhhhh') }.to raise_error(Pigment::Color::InvalidColorFormatError)
    end

    it 'raises Invalid hex color format Pigment::Color::InvalidColorFormatError with invalid Number' do
      expect { Pigment::Color::RGB.from_hex('0xFFFFFFFFF') }.to raise_error(Pigment::Color::InvalidColorFormatError)
      expect { Pigment::Color::RGB.from_hex('-5') }.to raise_error(Pigment::Color::InvalidColorFormatError)
    end

    it 'raises Invalid hex color format Pigment::Color::InvalidColorFormatError with invalid Object' do
      expect { Pigment::Color::RGB.from_hex(Object.new) }.to raise_error(Pigment::Color::InvalidColorFormatError)
    end
  end

  describe '::from_rgb(a)' do

    it 'creates a color from 4 numbers' do
      expect(Pigment::Color::RGB.from_rgba_integers(255, 255, 255, 255)).to eq rgb_white
    end

    it 'defaults alpha to 1' do
      expect(Pigment::Color::RGB.from_rgb_integers(255, 255, 255)).to eq rgb_white
    end

    it 'defaults alpha to 1' do
      expect(Pigment::Color::RGB.from_rgb_integers(255, 255, 255)).to eq rgb_white
    end

    it 'does not accept arguments other than numbers' do
      expect do
        Pigment::Color::RGB.from_rgb_integers(Object.new, Object.new, Object.new)
      end.to raise_error(Pigment::Color::InvalidColorFormatError)
    end
  end

  describe '::random' do
    it 'returns a random color' do
      expect(Pigment::Color::RGB.random).to be_a Pigment::Color::RGB
    end
  end

  describe '::new' do
    it 'accepts integers and floats' do
      expect(Pigment::Color::RGB.new(1.0, 0.0, 0)).to eq rgb_red
    end

    it 'does not accept non numeric values' do
      expect { Pigment::Color::RGB.new(Object.new, 0, 0) }.to raise_error NoMethodError
    end

    it "should be created even with approximation errors" do
      expect { Pigment::Color::RGB.new(0.8063725490196079, 1.0000000000000004, 0.8666666666666667, 1.0) }.not_to raise_error
    end
  end

  describe '#dup' do
    it 'creates a copy' do
      expect(rgb_black.dup).to eq rgb_black
    end
  end

  describe '#graysacle' do
    it 'won\'t affect black or white' do
      expect(rgb_black.grayscale).to eq rgb_black
      expect(rgb_white.grayscale).to eq rgb_white
    end

    it 'will convert into grayscale' do
      expect(rgb_red.grayscale).to eq rgb_blue.grayscale
      expect(rgb_green.grayscale).to eq rgb_blue.grayscale
    end
  end

  describe '#grayscale?' do
    it 'returns true when color is grayscale' do
      expect(rgb_black).to be_grayscale
      expect(rgb_white).to be_grayscale
      expect(rgb_blue.grayscale).to be_grayscale
    end

    it 'returns false when color is not grayscale' do
      expect(rgb_red).not_to be_grayscale
      expect(rgb_green).not_to be_grayscale
      expect(rgb_blue).not_to be_grayscale
    end
  end

  describe '#==' do
    it 'returns true when colors are the same' do
      expect(rgb_black == rgb_black).to be true
    end

    it 'returns false when comparing with an object' do
      expect(rgb_black == Object.new).to be false
    end
  end

  describe '#+' do
    it 'accepts another Pigment::Color' do
      expect(rgb_black + rgb_red).to eq rgb_red
      expect(rgb_white + rgb_black).to eq rgb_white
      expect(rgb_red + rgb_green).to eq Pigment::Color::RGB.new(1.0, 1.0, 0)
      expect(Pigment::Color::RGB.new(1.0, 1.0, 0) + rgb_red).to eq Pigment::Color::RGB.new(1.0, 0.5, 0)
      expect(rgb_black + hsl_red).to eq rgb_red
    end

    it 'does not accept anything else' do
      expect { rgb_white + Object.new }.to raise_error(Pigment::Color::InvalidColorFormatError)
    end
  end

  describe '#-' do
    it 'accepts another Pigment::Color' do
      expect(rgb_white - rgb_white).to eq rgb_black
      expect(rgb_white - rgb_black).to eq rgb_white
      expect(rgb_red - rgb_green).to eq rgb_red
      expect(Pigment::Color::RGB.new(1.0, 1.0, 0) - rgb_red).to eq rgb_green
      expect(Pigment::Color::RGB.new(1.0, 0.5, 0.2) - Pigment::Color::RGB.new(0.5, 1.0, 0.2)).to eq Pigment::Color::RGB.new(0.5, 0.0, 0.0)
    end

    it 'does not accept anything else' do
      expect { rgb_white - Object.new }.to raise_error(Pigment::Color::InvalidColorFormatError)
    end
  end

  describe '#*' do
    it 'accepts Numeric values' do
      expect(rgb_red * 2).to eq rgb_red
      expect(Pigment::Color::RGB.new(1.0, 0.5, 0.2) * 2).to eq Pigment::Color::RGB.new(1.0, 0.5, 0.2)
      expect(rgb_red * 0.5).to eq Pigment::Color::RGB.new(0.5, 0.0, 0.0)
    end

    it 'does not accept anything else' do
      expect { rgb_white * Object.new }.to raise_error(ArgumentError)
    end
  end

  describe '#/' do
    it 'accepts Numeric values' do
      expect(rgb_red / 0.5).to eq rgb_red
      expect(Pigment::Color::RGB.new(1.0, 0.5, 0.2) / 0.5).to eq Pigment::Color::RGB.new(1.0, 0.5, 0.2)
      expect(rgb_red / 2).to eq Pigment::Color::RGB.new(0.5, 0.0, 0.0)
    end

    it 'does not accept anything else' do
      expect { rgb_white / Object.new }.to raise_error(ArgumentError)
    end
  end

  describe '#inverse' do
    it 'returns the opposite color' do
      expect(rgb_white.inverse).to eq rgb_black
      expect(rgb_black.inverse).to eq rgb_white
      expect(rgb_red.inverse).to eq rgb_cyan
      expect(rgb_cyan.inverse).to eq rgb_red
    end
  end

  describe '#inverse?' do
    it 'returns true when other color is inverse of color' do
      expect(rgb_white.inverse?(rgb_black)).to be true
      expect(rgb_black.inverse?(rgb_white)).to be true
      expect(rgb_red.inverse?(rgb_cyan)).to be true
      expect(rgb_cyan.inverse?(rgb_red)).to be true
    end

    it 'returns false when other color is not inverse of color' do
      expect(rgb_white.inverse?(rgb_white)).to be false
      expect(rgb_black.inverse?(rgb_black)).to be false
    end
  end

  describe '#triadic' do
    it 'red triadic colors are blue and yellow' do
      expect(rgb_red.triadic).to eq [rgb_green, rgb_blue]
      expect(rgb_green.triadic).to eq [rgb_blue, rgb_red]
      expect(rgb_blue.triadic).to eq [rgb_red, rgb_green]
      expect(Pigment::Color::RGB.new(1.0, 0.25, 0.5).triadic).to eq [
          Pigment::Color::RGB.new(0.5, 1.0, 0.25),
          Pigment::Color::RGB.new(0.25, 0.5, 1.0)
      ]
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
    end

    it 'returns false if a color does not have a triadic relationship with the given color' do
      expect(rgb_red.triadic_of?(rgb_yellow)).to be false
      expect(rgb_green.triadic_of?(rgb_yellow)).to be false
      expect(rgb_blue.triadic_of?(rgb_yellow)).to be false
      expect(rgb_yellow.triadic_of?(rgb_green)).to be false
      expect(rgb_yellow.triadic_of?(rgb_blue)).to be false
      expect(rgb_yellow.triadic_of?(rgb_red)).to be false
    end
  end

  describe '#triadic_includes?' do
    it 'returns true' do
      expect(rgb_red.triadic_include?(rgb_blue, rgb_green)).to eq true
      expect(rgb_green.triadic_include?(rgb_blue, rgb_red)).to eq true
      expect(rgb_blue.triadic_include?(rgb_red, rgb_green)).to eq true
    end

    it 'returns false' do
      expect(rgb_red.triadic_include?(rgb_blue, rgb_green)).to eq true
      expect(rgb_green.triadic_include?(rgb_blue, rgb_red)).to eq true
      expect(rgb_blue.triadic_include?(rgb_red, rgb_green)).to eq true
    end
  end

  describe '#analogous' do
    it 'returns an array with 2 analagous colours' do
      expect(rgb_red.analogous.map(&:to_hex)).to eq ['ff007fff', 'ff7f00ff']
    end
  end

  describe '#interpolate' do
    it 'interpolates two colors' do
      expect(rgb_red.interpolate(rgb_blue)).to eq Pigment::Color::RGB.new(0.5, 0.0, 0.5)
    end

    it 'does not accept an amount outside -1.0 to 1.0 range' do
      expect { rgb_red.interpolate(rgb_blue, 1.9) }.to raise_error ArgumentError
    end

    it 'does not accept anything other than colors' do
      expect { rgb_red.interpolate(Object.new) }.to raise_error Pigment::Color::InvalidColorFormatError
    end
  end

  describe '#to_ints' do
    it 'returns an array of integer values' do
      expect(rgb_white.to_ints).to eq [255, 255, 255, 255]
      expect(rgb_red.to_ints).to   eq [255,   0,   0, 255]
      expect(rgb_green.to_ints).to eq [  0, 255,   0, 255]
      expect(rgb_blue.to_ints).to  eq [  0,   0, 255, 255]
      expect(rgb_black.to_ints).to eq [  0,   0,   0, 255]
    end
  end

  describe '#to_hex' do
    it 'returns a hexadecimal sring representing the color' do
      expect(rgb_white.to_hex).to eq "ffffffff"
      expect(rgb_red.to_hex).to   eq "ff0000ff"
      expect(rgb_green.to_hex).to eq "00ff00ff"
      expect(rgb_blue.to_hex).to  eq "0000ffff"
      expect(rgb_black.to_hex).to eq "000000ff"
    end
  end

  describe '#to_html' do
    it 'returns an html friendly string' do
      expect(rgb_white.to_html(with_alpha: true)).to eq "#ffffffff"
      expect(rgb_red.to_html(with_alpha: true)).to   eq "#ff0000ff"
      expect(rgb_green.to_html(with_alpha: true)).to eq "#00ff00ff"
      expect(rgb_blue.to_html(with_alpha: true)).to  eq "#0000ffff"
      expect(rgb_black.to_html(with_alpha: true)).to eq "#000000ff"
      expect(rgb_white.to_html).to eq "#ffffff"
      expect(rgb_red.to_html).to   eq "#ff0000"
      expect(rgb_green.to_html).to eq "#00ff00"
      expect(rgb_blue.to_html).to  eq "#0000ff"
      expect(rgb_black.to_html).to eq "#000000"
    end
  end

  describe '#to_s' do
    it 'returns a string representation' do
      expect(rgb_red.to_s).to eq "RGB Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)"
      expect(rgb_green.to_s).to eq "RGB Color(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)"
      expect(rgb_blue.to_s).to eq "RGB Color(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)"
      expect(rgb_black.to_s).to eq "RGB Color(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)"
      expect(rgb_white.to_s).to eq "RGB Color(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)"
    end
  end

  describe '#method_missing' do
    it 'swizzles the color' do
      expect(rgb_red.rrrr).to eq [1.0, 1.0, 1.0, 1.0]
    end

    it 'returns an error if the method is not recognized' do
      expect { rgb_red.something }.to raise_error NoMethodError
    end
  end
end