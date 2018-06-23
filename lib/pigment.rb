module Pigment
  VERSION = '0.3.2'.freeze

  class Color

    @named_colors = {}
    attr_reader :color, :hsl

    # Creates a Pigment::Color from an HTML Hex code String
    # @param [String] hex
    # @return [Pigment::Color]
    def self.from_hex(hex)
      raise ArgumentError, "Invalid hex color format: #{hex.inspect}" unless /^#(?<r>\h{2})(?<g>\h{2})(?<b>\h{2})(?<a>\h{2})?$/ =~ hex
      color = [r, g, b, a || 'ff'].map { |v| v.to_i(16) / 255.0 }
      new(*color)
    end

    # Creates a Pigment::Color from a group of rgba Integers
    # @return [Pigment::Color]
    # @param [Integer] r
    # @param [Integer] g
    # @param [Integer] b
    # @param [Integer] a
    def self.from_rgba(r, g, b, a = 255)
      color = [r, g, b, a]
      raise ArgumentError, "Invalid Integer color format: #{color.inspect}" unless color.all? { |c| (0..255).include?(c) && c.is_a?(Integer) }
      color.map { |c| c / 255.0 }
      new(*color)
    end

    def self.from_rgb(r, g, b)
      from_rgba(r, g, b)
    end

    # Creates a Pigment::Color form the HSL color System. It's mostly used to calculate harmonic colors.
    # @param [Float] h
    # @param [Float] s
    # @param [Float] l
    # @return [Pigment::Color]
    def self.from_hsl(h, s, l)
      return new(l, l, l) if s == 0
      v2 = l < 0.5 ? l * (1 + s) : (l + s) - (s * l)
      v1 = 2 * l - v2
      color = [h + (1 / 3.0), h, h - (1 / 3.0)].map do |hv|
        case
        when hv < 0 then hv += 1
        when hv > 1 then hv -= 1
        when 6 * hv < 1 then v1 +(v2 - v1) * 6 * hv
        when 2 * hv < 1 then v2
        when 3 * hv < 2 then v1 + (v2 - v1) * ((2 / 3.0)- hv) * 6
        else v1
        end
      end
      new(*color)
    end

    # Return specified color by its name from the named_colors hash.
    # @param [Symbol] name
    # @return [Array]
    def self.[](*colors)
      colors.size > 1 ? colors.map { |color| @named_colors[color] } : @named_colors[colors[0]]
    end

    # Add name to a color , add it to the named_colors hash and defines a constant.
    # @param [Array of Strings] names
    # @param [Pigment::Color] color
    def self.[]=(*names, color)
      raise ArgumentError, "Expects Pigment::Color but got #{color.inspect}" unless color.is_a? Color
      names.each do |name|
        @named_colors[name.downcase] = color
        const_set("#{name}".to_sym, color)
      end
    end

    # Return all the named_colors as an array.
    def self.named_colors
      @named_colors.keys
    end

    # Return all the named_colors as a sorted array.
    def self.named_colors_sorted
      named_colors.sort
    end

    # Suppress an array of floats by dividing by the greatest color component.
    # @param [Array] color
    # @return [Array]
    def self.suppress(color)
      color.map!  { |c| c / color.max } unless (0.0..1.0).include?(color.max)
      color
    end

    # Pigment uses sRGB or sRGBA as the default color system
    # Pigment::Color is represented as an array of floats, which are ranged from 0.0 to 1.0
    # @param [Float] r
    # @param [Float] g
    # @param [Float] b
    # @param [Float] a
    # @return [Pigment::Color]
    def initialize(r, g, b, a = 1.0)
      color = [r, g, b, a]
      raise ArgumentError, "Invalid Float color format: #{color.inspect}" unless color.all? { |c| (0.0..1.0).include?(c) && c.is_a?(Float) }
      @color = color
    end

    # Getters and Setters.
    %w'r g b a'.each_with_index do |m, i|
      define_method("#{m}", ->() { @color[i] })
      define_method("#{m}=", ->(value) { @color[i] = value if value.is_a?(Float) && (0.0..1.0).include?(value) })
    end

    %w'h s l'.each_with_index do |m, i|
      define_method("#{m}", ->() { hsl[i] })
    end

    def method_missing(method, *args)
      # Returns an array with the respective rgba components
      # @return [Array]
      super unless method =~ /(a|b|g|r)+/ && args.empty?
      method.size.times.map{ |i| send(method[i]) }
    end

    # Same as inverse.
    def -@
      inv
    end

    # Sums all the two colors components. If any component gets out of the 0 to 1.0 range its suppressed.
    # @param [Numeric] color
    # @return [Pigment::Color]
    def +(color)
      case color
      when Color
        self.class.new(*self.class.suppress([color.rgb, rgb].transpose.map! { |c, d| c + d }))
      else
        raise ArgumentError, "Expecting Color. Given #{color.class}"
      end
    end

    # Subtracts all the two color components. If any component gets out of the 0 to 1.0 range its suppressed.
    # If tone component gets lower than 0 it acts like its dealing with the inverse component -> 1 - component
    # @param [Numeric] color
    # @return [Pigment::Color]
    def -(color)
      case color
      when Color
        self.class.new(*self.class.suppress([rgb, color.rgb].transpose.map! do |c, d|
          e = c - d
          e >= 0 ? e : e = 1 + e
          e
        end))
      else
        raise ArgumentError, "Expecting color. Given #{color.class}"
      end
    end

    # Multiplies all the color components by n. If any component gets out of the 0 to 1.0 range its suppressed.
    # @param [Numeric] n
    # @return [Pigment::Color]
    def *(n)
      case n
      when Numeric
        n = rgb.map { |c| c * n.to_f }
        self.class.new(*self.class.suppress(n))
      else
        raise ArgumentError, "Expecting Numeric. Given #{n.class}"
      end
    end

    # Divides all the color components by n. If any component gets out of the 0 to 1.0 range its suppressed.
    # @param [Numeric] n
    # @return [Pigment::Color]
    def /(n)
      case n
      when Numeric
        n = rgb.map { |c| c * n.to_f }
        self.class.new(*self.class.suppress(n))
      else
        raise ArgumentError, "Expecting Numeric. Given #{n.class}"
      end
    end

    # Test if two colors are equal
    # @param [Pigment::Color] color
    # @return [Boolean]
    def ==(color)
      color.is_a?(Color) && color.rgba == rgba
    end

    # @return [Pigment::Color]
    def dup
      self.class.new(*@color)
    end

    # Converts a color to its grayscale correspondent
    # @return [Pigment::Color]
    def grayscale
      r = g = b = (self.r + self.g + self.b) / 3
      self.class.new(r, g, b)
    end

    # Calculates the harmonic colors. Type can be :triadic, :split, :analogous, :complement or :complementary
    # @param [Symbol] type
    # @return [Color, Array of Colors]
    def harmonize(type = :triadic)
      color.to_hsl unless @hsl
      case type
      when :triadic
        [self.class.from_hsl(h - 5 / 12.0, s, l), self.class.from_hsl(h + 1 / 3.0, s, l)]
      when :split
        [self.class.from_hsl(h - 5 / 12.0, s, l), self.class.from_hsl(h + 5 / 12.0, s, l)]
      when :analogous
        [self.class.from_hsl(h - 1 / 12.0, s, l), self.class.from_hsl(h + 1 / 12.0, s, l)]
      when :complement, :complementary
        inv
      else
        raise ArgumentError, "Expected :triadic, :split, :analogous, :complement or :complementary. Given #{type}"
      end
    end

    # Interpolates two colors. Amount must be an float between -1.0 and 1.0
    # @param [Color] color
    # @param [Float] amount
    def interpolate(color, amount = 0.5)
      if color.is_a?(Color) && (-1.0..1.0).include?(amount)
        n = [rgb, color.rgb].transpose.map! { |c, d| c + amount * (d - c) }
        self.class.new(*self.class.suppress(n))
      else
        raise ArgumentError
      end
    end

    # Returns the Invert color
    # @return [Color]
    def inverse
      self.class.new(*rgb.map { |c| 1.0 - c })
    end

    # Returns a new Color without the given channels
    # @param [Array of Symbols] channels
    # @return [Color]
    def remove_channels(*channels)
      color = self.class.new(r, g, b, a)
      %w'r g b a'.each { |attr| color.send("#{attr}=", 0) if channels.include? attr.to_sym }
      color
    end

    # Creates an instance variable to keep the HSL values of a RGB color.
    # @return [Array]
    def to_hsl
      min   = rgb.min
      max   = rgb.max
      delta = (max - min)
      l     = (max + min) / 2.0

      s = if delta == 0.0 # close to 0.0, so it's a grey
            h = 0
            0
          elsif l < 0.5
            delta / (max + min)
          else
            delta / (2.0 - max - min)
          end

      h = if r == max
            h = ((g - b) / delta) / 6.0
            h += 1.0 if g < b
            h
          elsif g == max
            ((b - r) / delta) / 6.0 + (1.0 / 3.0)
          elsif b == max
            ((r - g) / delta) / 6.0 + (2.0 / 3.0)
          end

      h += 1 if h < 0
      h -= 1 if h > 1
      @hsl = [h, s, l]
      self
    end

    # Returns an array of the color components. Alpha value is passed as well if with_alpha is set to true.
    # @param [Boolean] with_alpha
    # @return [Array]
    def to_floats(with_alpha = true)
      with_alpha ? @color.dup : rgb
    end

    # Returns an array of the color components. Alpha value is passed as well if with_alpha is set to true.
    # @param [Boolean] with_alpha
    # @return [Array]
    def to_ints(with_alpha = true)
      to_floats(with_alpha).map { |v| Integer(v * 255) }
    end

    # Returns an array of the color components. Alpha value is passed as well if with_alpha is set to true.
    # @param [Boolean] with_alpha
    # @return [Array]
    def to_hex(with_alpha = true)
      to_ints(with_alpha).map { |v| '%02x' % v }.join
    end

    def to_s
      "Color(r: #{r}, g: #{g}, b: #{b}, a: #{a}#{", [h: #{h}, s: #{s}, l: #{l}]" if @hsl})"
    end

    alias_method :alpha=,        :a=
    alias_method :inv,           :inverse
    alias_method :invert,        :inverse
    alias_method :complementary, :inverse
    alias_method :mix,           :interpolate
    alias_method :red,           :r
    alias_method :green,         :g
    alias_method :blue,          :b
    alias_method :alpha,         :a
    alias_method :to_a,          :to_floats
    alias_method :to_ary,        :to_floats
    alias_method :to_f,          :to_floats
    alias_method :to_hsl,        :hsl
  end
end

require_relative 'colors.rb'