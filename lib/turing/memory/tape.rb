module Turing
  module Memory
    class Tape
      extend Forwardable
      def_delegators :current_cell, :read, :write, :erase
      def_delegator :position, :shift, :move

      def current_cell
        position.find(cells)
      end

      def position
        @position ||= TapePosition.new
      end

      def cells
        @cells ||= {}
      end
    end
  end
end
