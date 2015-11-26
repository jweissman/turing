module Turing
  module Processor
    class InstructionRunner
      extend Forwardable

      def_delegators :@instruction, :move?, :erase?, :write?, :direction
      def_delegators :@machine, :move, :write, :erase

      def initialize(instruction, program, machine)
        @instruction = instruction
        @program     = program
        @machine     = machine
      end

      def handle!
        handle_io
        handle_movement
      end

      def next_state
        next_state_name = @instruction.next_state
        @program.find next_state_name
      end

      protected

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
