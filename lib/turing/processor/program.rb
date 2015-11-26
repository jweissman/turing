module Turing
  module Processor
    class Program
      attr_reader :states

      def initialize
        @states = [halt_state]
        yield self if block_given?
      end

      def state(name,*opts,&blk)
        new_state = State.new(name,*opts,&blk)
        @states.push new_state
      end

      def find(name)
        states.detect { |state| state.name == name }
      end

      def state_names
        states.collect(&:name)
      end

      def halt_state
        State.new :halt
      end

      def method_missing(sym,*args,&blk)
        state(sym,*args,&blk)
      end

      def validate!
        validator.check!
      end 

      protected
      def validator
        @validator ||= ProgramValidator.new(self)
      end
    end
  end
end

