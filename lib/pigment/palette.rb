require_relative 'color/rgb'

module Pigment
  # Represents a collection of named colors, for convenience
  class Palette
    include Enumerable

    # @return [{Object: Pigment::Color}]
    attr_reader :colors

    # @param [{Object => Pigment::Color}] colors
    def initialize(**colors)
      raise ArgumentError, "Pallete only accept colors" unless colors.values.all? {|color| color.is_a?(Pigment::Color)}
      @colors = colors
    end

    # @param [Proc] block
    # @return [Pigment::Palette] if block is passed
    # @return [Enumerable] otherwise
    def each(&block)
      return to_enum(__method__) unless block_given?
      @colors.each(&block)
      self
    end

    # Fetches the colors by names
    # @param [Array] names
    # @return [Pigment::Color] if only one result is found
    # @return [Array<Pigment::Color>]
    def [](*names)
      colors = @colors.fetch_values(*names)
      colors.size == 1 ? colors.first : colors
    end

    # Adds colors to the Palette with possible multiple names
    # @param [Array] names
    # @param [Pigment::Color] color
    # @return [Pigment::Color]
    def []=(*names, color)
      raise ArgumentError, "Expects Pigment::Color but got #{color.inspect}" unless color.is_a? Pigment::Color
      names.each { |name| @colors[name] = color }
      color
    end

    # Adds a color or a Hash containing Colors as values
    # @param [Pigment::Palette, Hash{Object => Pigment::Color}] other
    # @return [Pigment::Palette]
    def +(other)
      case other
      when Pigment::Palette
        @colors.merge!(other.to_h)
      when Hash
        @colors.merge!(other) if other.values.all?(Pigment::Color)
      else raise ArgumentError, "Invalid operand \"#{other.inspect}:#{other.class}\" for +"
      end
      self
    end

    # Removes a color via its key or value
    # @param [Object, Pigment::Color] other
    # @return [Pigment::Palette, Pigment::Color, nil]
    def -(other)
      return @colors.delete(other) unless other.is_a? Pigment::Color
      @colors.delete_if {|_, color| other == color}
      self
    end

    # @param [Object] other
    # @return [Boolean]
    def ==(other)
      self.class == other.class && @colors == other.to_h
    end

    # @return [{Object => Pigment::Color}] An Hash representation of the Palette
    def to_h
      @colors.dup
    end

    # @return [Array<Object>] An array including all the defined color names
    def names
      @colors.keys
    end

    # @return [Array<Pigment::Color>] An array including all the defined colors
    def colors
      @colors.values
    end

    private
    # Will retrieve the color from the Palette as a method call
    # @param [Symbol] method the color name
    # @param [Array] args will be ignored
    # @return [Pigment::Color] The requested color
    def method_missing(method, *args)
      return super unless args.empty?
      @colors[method] || @colors[method.to_s] || super
    end
  end
end