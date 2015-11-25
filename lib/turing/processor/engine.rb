module Turing
  module Processor
    class Engine
      EXECUTION_LIMIT = 10_000
      extend Forwardable

      attr_reader :counter

      def_delegators :@machine, :move, :read, :write

      def initialize(machine)
        @machine = machine
      end

      def operate(program)
        @state = program.find :start
        @state = iterate program until stop_iteration?
      end

      def tick!
        @counter ||= 0
        @counter += 1
      end
      
      def iterate(program)
        tick!

        instruction = next_instruction
        write if instruction.write?
        move instruction.direction if instruction.direction
        program.find instruction.next_state
      end

      def halted?
        @state.name == :halt
      end

      def stop_iteration?
        halted? || (@counter ||= 0) >= EXECUTION_LIMIT
      end

      def next_instruction
        state_options = @state.instruction_table
        state_options[read] || state_options[:any]
      end
    end
  end
end

