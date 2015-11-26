module Turing
  module Processor
    class State
      attr_reader :name, :instructions

      def initialize(name)
        @name = name
        @instructions = []
        yield self if block_given?
      end

      def on(sym, *opts)
        @instructions << Instruction.new(sym, *opts)
        self
      end

      def always(*opts)
        on(:any, *opts)
      end

      def instruction_table
        @instructions.inject({}) do |hash, instruction|
          hash[instruction.symbol] = instruction
          hash
        end
      end
    end
  end
end
