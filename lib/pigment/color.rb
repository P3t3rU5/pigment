require_relative '../pigment'

module Pigment
  # Represent an abstract color in any format
  module Color
    class << self
      # @param [#to_f] red
      # @param [#to_f] blue
      # @param [#to_f] green
      # @param [#to_f] alpha
      # @return [Pigment::Color::RGB]
      def rgba(red, blue, green, alpha = 1.0)
        Pigment::Color::RGB.new(red, blue, green, alpha)
      end

      # @param [Integer] hue between 0 and 360 degrees
      # @param [#to_f] saturation between 0.0 and 1.0
      # @param [#to_f] lightness between 0.0 and 1.0
      # @param [#to_f] alpha between 0.0 and 1.0
      # @return [Pigment::Color::HSL]
      def hsla(hue, saturation, lightness, alpha = 1.0)
        Pigment::Color::HSL.from_hue_angle(hue, saturation, lightness, alpha)
      end

      alias_method :rgb, :rgba
      alias_method :hsl, :hsla

      # sets aliases for any color format
      # @param [Class] klass
      def included(klass)
        klass.alias_method :gray?,         :grayscale?
        klass.alias_method :-@,            :inverse
        klass.alias_method :inv,           :inverse
        klass.alias_method :invert,        :inverse
        klass.alias_method :complementary, :inverse
        klass.alias_method :complement,    :inverse
        klass.alias_method :to_floats,     :to_a
        klass.alias_method :to_f,          :to_a
        klass.alias_method :inspect,       :to_s
      end
    end

    # @param [Class] color_type
    # @return [Pigment::Color]
    def into(color_type)
      color_type.convert(self)
    end

    # @return [Pigment::Color]
    def dup
      self.class.new(*to_a)
    end

    # @return [Pigment::Color]
    def inverse
      into(Pigment::Color::RGB).inverse.into(self.class)
    end

    # @param [Object] other
    # @return [Boolean]
    def inverse?(other)
      other.is_a?(Pigment::Color) && self.inverse == other
    end

    # @return [Array<Pigment::Color>]
    def triadic
      into(Pigment::Color::RGB).triadic.map { |color| color.into(self.class) }
    end

    # @param [Object] other
    # @return [Boolean]
    def triadic_of?(other)
      other.into(self.class)
      other.triadic.include?(self)
    end

    # @param [Array<Object>] others
    # @return [Boolean]
    def triadic_include?(*others)
      colors = triadic
      others.all? { |color| colors.include?(color) }
    end

    # @return [Array<Pigment::Color>]
    def split
      into(Pigment::Color::HSL).split.map { |color| color.into(self.class) }
    end

    # @param [Object] other
    # @return [Boolean]
    def split_of?(other)
      other.split.include?(self)
    end

    # @param [Array<Object>] others
    # @return [Boolean]
    def split_include?(*others)
      colors = split
      others.all? { |color| colors.include?(color) }
    end

    # @return [Array<Pigment::Color>]
    def analogous
      into(Pigment::Color::HSL).analogous.map { |color| color.into(self.class) }
    end

    # @param [Object] other
    # @return [Boolean]
    def analogous_of?(other)
      other.analogous.include?(self)
    end

    # @param [Array<Object>] others
    # @return [Boolean]
    def analogous_include?(*others)
      colors = analogous
      others.all? { |color| colors.include?(color) }
    end

    # @return [Array<Pigment::Color>]
    def tetradic
      into(Pigment::Color::HSL).tetradic.map { |color| color.into(self.class) }
    end

    # @param [Object] other
    # @return [Boolean]
    def tetradic_of?(other)
      other.tetradic.include?(self)
    end

    # @param [Array<Object>] others
    # @return [Boolean]
    def tetradic_include?(*others)
      others.all? { |color| tetradic.include?(color) }
    end

    # @return [Array<Pigment::Color>]
    def rectangular
      into(Pigment::Color::HSL).rectangular.map { |color| color.into(self.class) }
    end

    # @param [Object] other
    # @return [Boolean]
    def rectangular_of?(other)
      other.rectangular.include?(self)
    end

    # @param [Array<Object>] others
    # @return [Boolean]
    def rectangular_include?(*others)
      colors = rectangular
      others.all? { |color| colors.include?(color) }
    end

    # @return [Array<Pigment::Color>]
    def tertiary
      into(Pigment::Color::HSL).tertiary.map { |color| color.into(self.class) }
    end

    # @param [Object] other
    # @return [Boolean]
    def tertiary_of?(other)
      other.tertiary.include?(self)
    end

    # @param [Array<Object>] others
    # @return [Boolean]
    def tertiary_include?(*others)
      colors = tertiary
      others.all? { |color| colors.include?(color) }
    end

    # @param [Boolean] with_alpha
    # @return [String]
    def to_html(with_alpha: false)
      "##{to_hex(with_alpha: with_alpha)}"
    end

    # @param [Boolean] with_alpha
    # @return [Array<Integer>]
    def to_ints(with_alpha: true)
      into(Pigment::Color::RGB).to_ints(with_alpha: with_alpha)
    end

    # @param [Boolean] with_alpha
    # @return [String]
    def to_hex(with_alpha: true)
      into(Pigment::Color::RGB).to_hex(with_alpha: with_alpha)
    end
  end
end

require_relative 'color/rgb'
require_relative 'color/hsl'

