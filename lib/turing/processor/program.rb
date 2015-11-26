module Turing
  module Processor
    class Program
      attr_reader :states

      # def initialize
      #   yield self if block_given?
      #   validator.check self
      # end

      def self.build
        program = Program.new
        yield program
        validator.check(program)
        program
      end

      def state(name,*opts,&blk)
        @states ||= [halt_state]
        new_state = State.new(name,*opts,&blk)
        @states.push new_state
      end

      def find(name)
        @states.detect { |state| state.name == name }
      end

      def state_names
        @states.collect(&:name)
      end

      def halt_state
        State.new :halt
      end

      def method_missing(sym,*args,&blk)
        state(sym,*args,&blk)
      end

      protected

      def self.validator
        @validator ||= ProgramValidator.new
      end
    end
  end
end

