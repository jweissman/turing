module Turing
  module Processor
    class Program
      attr_reader :states

      def initialize
        yield self if block_given?
        validator.check self
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

      protected

      def validator
        @validator ||= ProgramValidator.new
      end
    end
  end
end

