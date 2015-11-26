module Turing
  module Processor
    class ProgramValidator
      attr_reader :program

      def initialize(program)
        @program = program
      end

      def check!
        instructions.each(&method(:validate_transition!))
      end

      protected
      def validate_transition!(instruction)
        state, state_names = instruction.next_state, program.state_names
        raise "Invalid state '#{state}'" unless state_names.include? state
      end

      private
      def instructions
        @instructions ||= program.states.collect(&:instructions).flatten
      end
    end
  end
end

