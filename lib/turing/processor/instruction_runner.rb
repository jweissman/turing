module Turing
  module Processor
    class InstructionRunner
      extend Forwardable

      def_delegators :@instruction, :move?, :erase?, :write?, :direction
      def_delegators :@machine, :move, :write, :erase
      def_delegators :@program, :find_next_state

      def initialize(instruction, machine, program)
        @instruction = instruction
        @machine     = machine
        @program     = program
      end

      def process
        handle_io and handle_movement
        next_state
      end

      def next_state
        find_next_state @instruction
      end

      def handle_movement
        move direction if move?
      end

      def handle_io
        write if write?
        erase if erase?
      end
    end
  end
end
