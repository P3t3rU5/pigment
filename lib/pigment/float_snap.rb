module Pigment
  module FloatSnap
    @snap_digits = 6
    class << self
      attr_accessor :snap_digits
    end

    refine Float do
      def snap
        round(Pigment::FloatSnap.snap_digits)
      end
    end
  end
end