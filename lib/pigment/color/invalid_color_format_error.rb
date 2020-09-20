module Pigment
  module Color
    # Error raised when an invalid color format is used
    class InvalidColorFormatError < ArgumentError
      def initialize(object)
        super("Invalid Format #{object.inspect}")
      end
    end
  end
end