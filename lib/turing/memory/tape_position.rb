module Turing
  module Memory
    class TapePosition
      def shift(direction)
        @index = index + offset(direction)
      end

      def find(hash)
        hash[index] ||= Cell.new
      end

      protected

      def offset(direction)
        offsets = { left: -1, right: 1 }
        offsets.fetch direction
      end

      def index
        @index ||= 0
      end
    end
  end
end
