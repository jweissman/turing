module Turing
  module Processor
    class Engine
      EXECUTION_LIMIT = 10_000
      extend Forwardable

      def_delegator :@state, :instruction_table, :instructions

      def_delegators :@machine, :move, :read, :write
      def_delegators :@program, :start

      def initialize(machine)
        @machine = machine
      end

      def operate(program)
        @program = ProgramHarness.new(program)
        run!
      end

      def run!
        @state = start
        iterate until stop_iteration?
      end

      def iterate
        tick! 
        handle next_instruction
      end

      def handle(instruction)
        @state = executor_for(instruction).process
      end

      def halted?
        @state.name == :halt
      end

      def executor_for(instruction)
        InstructionRunner.new(instruction, @machine, @program)
      end

      def stop_iteration?
        halted? || counter >= EXECUTION_LIMIT
      end

      def next_instruction
        instructions[read] || instructions[:any]
      end

      def counter
        @counter ||= 0
      end

      def tick!
        @counter = counter + 1
      end
    end
  end
end

