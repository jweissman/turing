module Turing
  module Processor
    class Engine
      EXECUTION_LIMIT = 10_000
      extend Forwardable

      def_delegators :@machine, :move, :read, :write

      def initialize(machine)
        @machine = machine
      end

      def operate(program)
        @state = program.find :start
        @state = iterate(program, next_instruction) until stop_iteration?
      end

      def halted?
        @state.name == :halt
      end

      def counter
        @counter ||= 0
      end

      def tick!
        @counter = counter + 1
      end

      protected
      def iterate(program, instruction)
        tick!
        handle instruction
        program.find instruction.next_state
      end

      def handle(instruction)
        write if instruction.write?
        move instruction.direction if instruction.direction
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

