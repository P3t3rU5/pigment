require_relative '../color'

module Pigment
  module Color
    # Represent a color in the HSL Format
    class HSL
      using FloatSnap

      # @return [Float]
      attr_reader :hue, :saturation, :lightness, :alpha

      class << self

        # Converts a color into HSL format from any possible format, given they know how to convert to RGB
        # @param [Pigment::Color] color
        # @return [Pigment::Color::HSL]
        def convert(color)
          return color if color.is_a?(self)
          color   = color.into(Pigment::Color::RGB)
          rgb     = color.rgb
          r, g, b = rgb

          min    = rgb.min
          max    = rgb.max
          chroma = max - min
          sum    = max + min
          l      = sum / 2.0

          return new(0, 0, l, color.alpha) if chroma == 0.0

          s = l > 0.5 ? chroma / (2.0 - sum) : chroma / sum

          h = case max
          when r then ((g - b) / chroma) / 6 + (g < b && 1 || 0)
          when g then ((b - r) / chroma) / 6.0 + (1.0 / 3.0)
          when b then ((r - g) / chroma) / 6.0 + (2.0 / 3.0)
          end

          new(h, s, l, color.alpha)
        end

        # @param [Integer] hue between 0 and 360 degrees
        # @param [#to_f] saturation between 0.0 and 1.0
        # @param [#to_f] lightness between 0.0 and 1.0
        # @param [#to_f] alpha between 0.0 and 1.0
        # @return [Pigment::Color::HSL]
        def from_hue_angle(hue, saturation, lightness, alpha = 1.0)
          new(hue / 360.0, saturation, lightness, alpha)
        end
      end

      # @param [#to_f] hue between 0.0 and 1.0 mapping to 0 to 360 degrees
      # @param [#to_f] saturation between 0.0 and 1.0
      # @param [#to_f] lightness between 0.0 and 1.0
      # @param [#to_f] alpha between 0.0 and 1.0
      # @return [Pigment::Color::HSL]
      # @raise [InvalidColorFormatError]
      def initialize(hue, saturation, lightness, alpha = 1.0)
        @hue        = hue % 1.0
        @saturation = saturation.to_f.snap
        @lightness  = lightness.to_f.snap
        @alpha      = alpha.to_f.snap

        color = to_f(with_alpha: true)
        raise InvalidColorFormatError, color unless color.all? { |c| c.between?(0.0, 1.0) }
      end

      # @return [Pigment::Color::HSL] the grayscale correspondent of the color
      def grayscale
        self.class.new(@hue, 0, @lightness, @alpha)
      end

      # @return [Boolean] true if saturation is 0, false otherwise
      def grayscale?
        @saturation == 0
      end

      # @return [Array<Pigment::Color>] An array with the triadic colors  of the color
      def triadic
        [self.class.new(@hue + 1 / 3.0, s, l), self.class.new(@hue + 2 / 3.0, s, l)]
      end

      # @return [Array<Pigment::Color>] An array with the split colors  of the color
      def split
        [self.class.new(@hue - 5 / 12.0, s, l), self.class.new(@hue + 5 / 12.0, s, l)]
      end

      # @return [Array<Pigment::Color>] An array with the analogous colors  of the color
      def analogous
        [self.class.new(@hue - 1 / 12.0, s, l), self.class.new(@hue + 1 / 12.0, s, l)]
      end

      # @return [Array<Pigment::Color>] An array with the tetradic colors  of the color
      def tetradic
        [
            self.class.new(@hue + 1 / 4.0, @saturation, @lightness),
            self.class.new(@hue + 1 / 2.0, @saturation, @lightness),
            self.class.new(@hue + 3 / 4.0, @saturation, @lightness)
        ]
      end

      # @return [Array<Pigment::Color>] An array with the rectangular colors  of the color
      def rectangular
        [
            self.class.new(@hue + 1 / 6.0, @saturation, @lightness),
            self.class.new(@hue + 1 / 2.0, @saturation, @lightness),
            self.class.new(@hue + 2 / 3.0, @saturation, @lightness)
        ]
      end

      # @return [Array<Pigment::Color>] An array with the tertiary colors  of the color
      def tertiary
        [
            self.class.new(@hue + 1 / 6.0, @saturation, @lightness),
            self.class.new(@hue + 1 / 3.0, @saturation, @lightness),
            self.class.new(@hue + 1 / 2.0, @saturation, @lightness),
            self.class.new(@hue + 2 / 3.0, @saturation, @lightness),
            self.class.new(@hue + 5 / 6.0, @saturation, @lightness),
        ]
      end

      # @param [Boolean] with_alpha
      # @return [Array<Float>] an array with the color components
      def to_a(with_alpha: true)
        with_alpha ? [@hue, @saturation, @lightness, @alpha] : [@hue, @saturation, @lightness]
      end

      # @return [String] the string representation of a hsl color
      def to_s
        "HSL Color(hue: #{hue}, saturation: #{saturation}, lightness: #{lightness}, alpha: #{alpha})"
      end

      # @param [Object] other
      # @return [Boolean] wether the color is equal to other object
      def ==(other)
        other = Pigment::Color::HSL.convert(other)
        other.hue.snap == @hue.snap &&
            other.saturation.snap == @saturation.snap &&
            other.lightness.snap == @lightness.snap &&
            other.alpha.snap == @alpha.snap
      end

      alias_method :a, :alpha
      alias_method :h, :hue
      alias_method :s, :saturation
      alias_method :l, :lightness

      include Pigment::Color

      private
      # @return [Array] an array with the respective hsla components
      def method_missing(method, *args)
        super unless method =~ /^[ahsl]+$/ && args.empty?
        method.to_s.each_char.map { |component| send(component) }
      end
    end
  end
end