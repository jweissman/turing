module Turing
  module Processor
    class Instruction
      attr_reader :symbol
      attr_reader :next_state, :should_write, :should_erase, :direction

      def initialize(
        symbol, 
        should_write: nil, 
        should_erase: nil,
        direction: nil, 
        transition_to: :halt
      )

        @symbol, @direction, @next_state = symbol, direction, transition_to
        @should_write, @should_erase     = should_write, should_erase
      end

      def erase?
        !!should_erase
      end

      def write?
        !!should_write
      end

      def move?
        !!direction
      end
    end
  end
end

