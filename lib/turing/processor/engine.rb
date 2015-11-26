module Turing
  module Processor

    module EngineComponents
      module Counting
        def counter
          @counter ||= 0
        end

        def tick!
          @counter = counter + 1
        end
      end

      module State
        extend Forwardable
        def_delegator :@state, :instruction_table, :instructions

        def transition_to(state)
          @state = state
        end

        def halted?
          @state.name == :halt
        end

        def initial_state_for(program)
          program.find :start
        end
      end
    end

    class Engine
      EXECUTION_LIMIT = 10_000
      extend Forwardable

      def_delegator :@machine, :read, :cell_value

      include EngineComponents::Counting
      include EngineComponents::State

      def initialize(machine)
        @machine = machine
      end

      def execute(program)
        transition_to initial_state_for(program)
        iterate program until stop_iteration?
      end

      protected
      def stop_iteration?
        halted? || counter >= EXECUTION_LIMIT
      end

      def next_instruction
        instructions[cell_value] || instructions[:any]
      end

      def executor_for(instruction, program)
        InstructionRunner.new(instruction, program, @machine)
      end

      private
      def handle(instruction, program)
        executor = executor_for(instruction, program)
        process_instruction_with executor
      end

      def process_instruction_with(execution)
        execution.handle!
        transition_to execution.next_state
      end

      def iterate(program)
        tick!
        handle(next_instruction, program)
      end
    end
  end
end

