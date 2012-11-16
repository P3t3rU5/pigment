module Pigment
  VERSION = '0.1.8'

  class Color

    @named_colors = {}
    attr_reader :color, :hsl

    # Pigment uses sRGB or sRGBA as the default color system
    # color can be a hexadecimal code preceded by a '#' like '#FF4CB2' or a array of floats (1.0, 0.3, 0.7)
    # or an array of integers between 0 and 255 (153, 255, 31)
    # @param [String, Array] color
    def initialize(*color)
      @color = case
               when color[0] =~ /^#([a-fA-F0-9]{2})([a-fA-F0-9]{2})([a-fA-F0-9]{2})([a-fA-F0-9]{2})?$/
                 [$1, $2, $3, $4 || 'ff'].map { |v| v.to_i(16) / 255.0 }
               when color.is_a?(Array) && (color.all? { |c| (0.0..1.0).include? c }) && color.length == 3
                 [color, 1.0].flatten!
               when color.is_a?(Array) && (color.all? { |c| (0..255).include? c && c.is_a?(Integer) } ) && color.length == 3
                 [color.map { |c| c / 255.0 }, 1.0].flatten!
               when color.is_a?(Array) && (color.all? { |c| (0.0..1.0).include? c }) && color.length == 4
                 color
               when color.is_a?(Array) && (color.all? { |c| (0..255).include? c && c.is_a?(Integer) } ) && color.length == 4
                 color.map { |c| c / 255.0 }
               else
                 raise ArgumentError, "Expected String or Array with length 3 or 4. Given #{color.class} with length = #{color.length}"
               end
    end

    # Selectors.
    %w'r g b a'.each_with_index do |m, i|
      define_method("#{m}", ->() { color[i] })
    end

    %w'h s l'.each_with_index do |m, i|
      define_method("#{m}", ->() { hsl[i] })
    end

    # Set alpha value. Only accepts float values
    # @param [Float] alpha
    def a=(alpha)
      @color[3] = alpha if alpha.is_a?(Float) && (0.0..1.0).include?(alpha)
    end

    # Returns an array with the rgb components
    # @return [Array]
    def rgb
      @color[0, 3]
    end

    def hsl
      to_hsl
      @hsl
    end

    # Return specified color by its name from the named_colors hash.
    # @param [Symbol] name
    # @return [Color]
    def self.[](name)
      @named_colors[name]
    end

    # Add name to a color , add it to the named_colors hash and defines a constant.
    # @param [Array of Strings] names
    # @param [Color] color
    def self.[]=(*names, color)
      color = new(color) unless color.is_a? Color
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


    # Supress an array of floats by dividing by the greatest color component.
    # @param [Array] color
    # @return [Array]
    def self.supress(color)
      color.map!  { |c| c / color.max } unless (0.0..1.0).include?(color.max)
      color
    end

    # Creates a Color form the HSL color System. It's mostly used to calculate harmonic colors.
    # @param [Float] h
    # @param [Float] s
    # @param [Float] l
    # @return [Color]
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

    # Same as inverse.
    def -@
      inv
    end

    # Sums all the two colors components. If any component gets out of the 0 to 1.0 range its supressed.
    # @param [Numeric] color
    # @return [Color]
    def +(color)
      case color
      when Color
        self.class.new(*supress([color.rgb, rgb].transpose.map! { |c, d| c + d }))
      else
        raise ArgumentError, "Expecting Color. Given #{color.class}"
      end
    end

    # Subtracts all the two color components. If any component gets out of the 0 to 1.0 range its supressed.
    # If tone component gets lower than 0 it acts like its dealing with the inverse component -> 1 - component
    # @param [Numeric] color
    # @return [Color]
    def -(color)
      case color
      when Color
        self.class.new(*self.class.supress([rgb, color.rgb].transpose.map! do |c, d|
          e = c - d
          e >= 0 ? e : e = 1 + e
          e
        end))
      else
        raise ArgumentError, "Expecting color. Given #{color.class}"
      end
    end

    # Multiplies all the color components by n. If any component gets out of the 0 to 1.0 range its supressed.
    # @param [Numeric] n
    # @return [Color]
    def *(n)
      case n
      when Numeric
        n = rgb.map { |c| c * n.to_f }
        self.class.new(*self.class.supress(n))
      else
        raise ArgumentError, "Expecting Numeric. Given #{n.class}"
      end
    end

    # Divides all the color components by n. If any component gets out of the 0 to 1.0 range its supressed.
    # @param [Numeric] n
    # @return [Color]
    def /(n)
      case n
      when Numeric
        n = rgb.map { |c| c * n.to_f }
        self.class.new(*self.class.supress(n))
      else
        raise ArgumentError, "Expecting Numeric. Given #{n.class}"
      end
    end

    # Test if two colors are equal
    # @param [Color] color
    # @return [Boolean]
    def ==(color)
      color.is_a?(Color) && color.rgb == rgb
    end

    # Converts a color to its grayscale correspondent
    # @return [Color]
    def grayscale
      r = g = b = (self.r + self.g + self.b)/3
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
      if color.is_a? Color && (-1.0..1.0).include?(amount)
        n = [rgb, color.rgb].transpose.map! { |c, d| c + amount * (d - c) }
        self.class.new(*self.class.supress(n))
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
      r = 0 if channels.include? :r
      g = 0 if channels.include? :g
      b = 0 if channels.include? :b
      self.class.new(r, g, b)
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
    def to_floats(with_alpha = false)
      with_alpha ? @color : rgb
    end

    # Returns an array of the color components. Alpha value is passed as well if with_alpha is set to true.
    # @param [Boolean] with_alpha
    # @return [Array]
    def to_ints(with_alpha = false)
      to_floats(with_alpha).map { |v| Integer(v * 255) }
    end

    # Returns an array of the color components. Alpha value is passed as well if with_alpha is set to true.
    # @param [Boolean] with_alpha
    # @return [Array]
    def to_hex(with_alpha = false)
      to_ints(with_alpha).map { |v| '%02x' % v }.join
    end

    def to_s
      "Color(r=#{r}, g=#{g}, b=#{b}, a=#{a}#{", [h=#{h}, s=#{s}, l=#{l}]" if @hsl})"
    end

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
  end
end

require_relative 'colors.rb'