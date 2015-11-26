module Turing
  module Processor
    class ProgramHarness
      def initialize(program)
        @program = program
      end

      def start
        @program.find(:start)
      end

      def find_next_state(instruction)
        @program.find instruction.next_state
      end 
    end
  end
end
