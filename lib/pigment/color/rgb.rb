require_relative '../color'

module Pigment
  module Color
    # Represent a color in the RGB Format
    class RGB
      using FloatSnap

      # @return [Float]
      attr_reader :red, :green, :blue, :alpha

      class << self
        # Converts a color into RGB format from any possible format
        # @param [Pigment::Color] color
        # @raise [InvalidColorFormatError]
        # @return [Pigment::Color]
        def convert(color)
          case color
          when RGB then color
          when HSL then from_hsl(*color)
          else raise InvalidColorFormatError, color
          end
        end

        # Creates a Pigment::Color::RGB from an HTML Hex code String
        # @param [String, Integer] hex
        # @raise [InvalidColorFormatError]
        # @return [Pigment::Color::RGB]
        def from_hex(hex)
          case hex
          when String  then from_hex_string(hex)
          when Integer then from_hex_integer(hex)
          when Float   then from_hex_integer(hex.round)
          else raise InvalidColorFormatError, hex
          end
        end

        # Creates a Pigment::Color from a group of rgba Integers
        # @param [Integer] red
        # @param [Integer] green
        # @param [Integer] blue
        # @param [Integer] alpha
        # @raise [InvalidColorFormatError]
        # @return [Pigment::Color::RGB]
        def from_rgba_integers(red, green, blue, alpha = 255)
          color = [red, green, blue, alpha]
          raise InvalidColorFormatError, color unless color.all? do |c|
            (0..255).include? c
          end
          new(*color.map { |c| c / 255.0 })
        end

        # @param [Integer] red
        # @param [Integer] green
        # @param [Integer] blue
        # @return [Pigment::Color::RGB]
        def from_rgb_integers(red, green, blue)
          from_rgba_integers(red, green, blue)
        end

        # @return [Pigment::Color::RGB] a random generated color
        def random
          new(rand(0.0..1.0), rand(0.0..1.0), rand(0.0..1.0))
        end

        # Suppress an array of floats by dividing by the greatest color component.
        # @param [Array] color
        # @return [Array]
        def suppress(color)
          return color.map { |c| c / color.max } unless color.max.between?(0.0, 1.0)
          color
        end

        private
        # @param [Integer] hex
        # @return [Pigment::Color::RGB]
        def from_hex_integer(hex)
          raise InvalidColorFormatError, hex unless hex.is_a?(Numeric) && hex.between?(0, 0xFFFFFFFF)
          red   = (hex >> 24 & 0xFF)
          green = (hex >> 16 & 0xFF)
          blue  = (hex >>  8 & 0xFF)
          alpha = (hex       & 0xFF)
          from_rgba_integers(red, green, blue, alpha)
        end

        # @param [String] hex
        # @raise [InvalidColorFormatError]
        # @return [Pigment::Color::RGB]
        def from_hex_string(hex)
          matches = hex.match(/^#?(?<r>\h{2})(?<g>\h{2})(?<b>\h{2})(?<a>\h{2})?$/)&.named_captures
          raise InvalidColorFormatError, hex unless matches
          matches["a"] ||= 'FF'
          new(*matches.values.map { |value| value.to_i(16) / 255.0 })
        end

        # Creates a Pigment::Color::RGB form the HSL color System. It's mostly used to calculate harmonic colors.
        # @param [#to_f] hue between 0.0 and 1.0
        # @param [#to_f] saturation between 0.0 and 1.0
        # @param [#to_f] lightness between 0.0 and 1.0
        # @param [#to_f] alpha between 0.0 and 1.0
        # @return [Pigment::Color::RGB]
        def from_hsl(hue, saturation, lightness, alpha = 1.0)
          return new(lightness, lightness, lightness, alpha) if saturation == 0
          v2 = lightness < 0.5 ? lightness * (1 + saturation) : lightness + saturation - saturation * lightness
          v1 = 2 * lightness - v2
          color = [hue + (1 / 3.0), hue, hue - (1 / 3.0)].map do |hv|
            hv = hv < 0 ? hv + 1
                : hv > 1 ? hv - 1
                : hv

            case
            when 6 * hv < 1 then v1 + (v2 - v1) * 6 * hv
            when 2 * hv < 1 then v2
            when 3 * hv < 2 then v1 + (v2 - v1) * ((2 / 3.0) - hv) * 6
            else v1
            end
          end
          color << alpha
          new(*color.map { |c| c.round(2) })
        end
      end

      # Pigment uses sRGB or sRGBA as the default color system
      # Pigment::Color::RGB is represented as an array of floats, which are ranged from 0.0 to 1.0
      # @param [Float, Integer] red between 0.0 and 1.0
      # @param [Float, Integer] green between 0.0 and 1.0
      # @param [Float, Integer] blue between 0.0 and 1.0
      # @param [Float, Integer] alpha between 0.0 and 1.0
      # @raise [InvalidColorFormatError]
      # @return [Pigment::Color::RGB]
      def initialize(red, green, blue, alpha = 1.0)
        @red, @green, @blue, @alpha = red.to_f, green.to_f, blue.to_f, alpha.to_f
        color = to_floats(with_alpha: true)
        raise InvalidColorFormatError, color unless color.all? { |c| c.between?(0.0, 1.0) }
      end

      # Sums all the two colors components. If any component gets out of the 0 to 1.0 range it gets suppressed.
      # @param [Pigment::Color] color
      # @raise [InvalidColorFormatError]
      # @return [Pigment::Color::RGB]
      def +(color)
        raise InvalidColorFormatError, color unless color.is_a?(Pigment::Color)
        color = color.into(self.class)
        color = [
            @red + color.red,
            @green + color.green,
            @blue + color.blue
        ]

        self.class.new(*self.class.suppress(color), @alpha)
      end

      # Subtracts all the two color components. If any component gets out of the 0 to 1.0 range it gets suppressed.
      # Tone component will be 0 if it gets lower than 0
      # @param [Pigment::Color] color
      # @raise [InvalidColorFormatError]
      # @return [Pigment::Color::RGB]
      def -(color)
        raise InvalidColorFormatError, color unless color.is_a?(Pigment::Color)
        color = color.into(self.class)
        self.class.new(*self.class.suppress([
            @red - color.red,
            @green - color.green,
            @blue - color.blue
        ].map { |c| c >= 0 ? c : 0 }), @alpha)
      end

      # Multiplies all the color components by n. If any component gets out of the 0 to 1.0 range it gets suppressed.
      # @param [Numeric] n
      # @return [Pigment::Color::RGB]
      def *(n)
        raise ArgumentError, "Expecting Numeric. Given #{n.class}" unless n.is_a? Numeric
        n = rgb.map { |c| c * n.to_f }
        self.class.new(*self.class.suppress(n), @alpha)
      end

      # Divides all the color components by n. If any component gets out of the 0 to 1.0 range it gets suppressed.
      # @param [Numeric] n
      # @return [Pigment::Color::RGB]
      def /(n)
        raise ArgumentError, "Expecting Numeric. Given #{n.class}" unless n.is_a? Numeric
        n =  rgb.map { |c| c / n.to_f }
        self.class.new(*self.class.suppress(n), @alpha)
      end

      # Test if two colors are equal
      # @param [Pigment::Color] other
      # @return [Boolean]
      def ==(other)
        return false unless other.is_a?(Pigment::Color)
        other = Pigment::Color::RGB.convert(other)
        other.red.snap       == @red.snap &&
            other.blue.snap  == @blue.snap &&
            other.green.snap == @green.snap &&
            other.alpha.snap == @alpha.snap
      end

      # @return [Pigment::Color::RGB] the grayscale correspondent of the color
      def grayscale
        gray = (@red + @green + @blue) / 3.0
        self.class.new(gray, gray, gray, @alpha)
      end

      # @return [Boolean] true if all components are the same, false otherwise
      def grayscale?
        @red == @green && @green == @blue
      end

      # Interpolates two colors. Amount must be an float between -1.0 and 1.0
      # @param [Pigment::Color] color
      # @param [Float] amount
      # @raise [InvalidColorFormatError]
      # @return [Pigment::Color::RGB]
      def interpolate(color, amount = 0.5)
        raise InvalidColorFormatError, color unless color.is_a?(Pigment::Color)
        raise ArgumentError, "Amount must be an float between -1.0 and 1.0, got #{amount}" unless (-1.0..1.0).include?(amount)
        color = color.into(Pigment::Color::RGB)
        n = [rgb, color.rgb].transpose.map! { |c, d| c + amount * (d - c) }
        self.class.new(*self.class.suppress(n))
      end

      # @return [RGB] the Invert color
      def inverse
        self.class.new(*rgb.map { |c| 1.0 - c }, @alpha)
      end


      # @return [Array<Pigment::Color>] An array of the triadic colors from self
      def triadic
        [self.class.new(@blue, @red, @green, @alpha), self.class.new(@green, @blue, @red, @alpha)]
      end

      # @param [Boolean] with_alpha
      # @return [Array<Float>] an array of the color components. Alpha value is passed as well if with_alpha is set to true.
      def to_a(with_alpha: true)
        with_alpha ? [@red, @green, @blue, @alpha] : [@red, @green, @blue]
      end

      # @param [Boolean] with_alpha
      # @return [Array<Integer>] an array of the color components. Alpha value is passed as well if with_alpha is set to true.
      def to_ints(with_alpha: true)
        to_a(with_alpha: with_alpha).map { |v| (v * 255).to_i }
      end

      # @param [Boolean] with_alpha
      # @return [String] an hexadecimal representation of the color components. Alpha value is passed as well if
      #   with_alpha is set to true.
      def to_hex(with_alpha: true)
        to_ints(with_alpha: with_alpha).map { |v| '%02x' % v }.join
      end

      # @return [Array<Float>] an array with the red, green and blue color components
      def rgb
        to_a(with_alpha: false)
      end

      # @return [String] the string representation of a hsl color
      def to_s
        "RGB Color(red: #{red}, green: #{green}, blue: #{blue}, alpha: #{alpha})"
      end

      alias_method :mix,  :interpolate
      alias_method :r,    :red
      alias_method :g,    :green
      alias_method :b,    :blue
      alias_method :a,    :alpha
      alias_method :rgba, :to_a

      include Pigment::Color

      private
      # @return [Array<Float>] an array with the respective rgba components
      def method_missing(method, *args)
        return super unless method =~ /^[abgr]+$/ && args.empty?
        method.size.times.map{ |i| send(method[i]) }
      end
    end
  end
end
