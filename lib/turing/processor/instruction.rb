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

        @symbol = symbol
        @should_write = should_write
        @should_erase = should_erase
        @direction = direction
        @next_state = transition_to
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

