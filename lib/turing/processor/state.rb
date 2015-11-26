module Turing
  module Processor
    class State
      attr_reader :name, :instructions

      def initialize(name)
        setup(name)
        yield self if block_given?
      end

      def setup(name)
        @name = name
        @instructions = []
      end

      def on(sym, *opts)
        @instructions << Instruction.new(sym, *opts)
        self
      end

      def always(*opts)
        on(:any, *opts)
      end

      def if_symbol_present(*opts)
        on(true, *opts)
      end

      def if_symbol_absent(*opts)
        on(false, *opts)
      end

      def instruction_table
        @instructions.inject({}, &method(:accumulate_instruction))
      end

      protected
      def accumulate_instruction(hash, instruction)
        hash[instruction.symbol] = instruction; hash
      end
    end
  end
end
