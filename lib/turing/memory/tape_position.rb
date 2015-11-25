module Turing
  module Memory
    class TapePosition
      def shift(direction)
        if direction == :right
          @index = index + 1
        elsif direction == :left
          @index = index - 1
        end
      end

      def find(hash)
        hash[index] ||= Cell.new
      end

      protected

      def index
        @index ||= 0
      end
    end
  end
end
