module Turing
  module Memory
    class Cell
      def read
        inscribed?
      end

      def write
        @inscribed = true
      end

      def erase
        @inscribed = false
      end

      def inscribed?
        @inscribed ||= false
      end
    end
  end
end
