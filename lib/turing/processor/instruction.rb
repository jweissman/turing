module Turing
  module Processor
    class Instruction
      attr_reader :symbol
      attr_reader :next_state, :should_write, :direction

      def initialize(symbol, should_write: nil, direction: nil, next_state: :halt)
        @symbol = symbol
        @should_write = should_write
        @direction = direction
        @next_state = next_state
      end

      def write?
        !!should_write
      end
    end
  end
end

