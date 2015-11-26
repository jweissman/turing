module Turing
  class Machine
    extend Forwardable

    def_delegators :tape, :read, :write, :erase, :move
    def_delegators :engine, :halted?, :counter, :execute

    def run!(program, verify_only: false)
      validate program
      execute program unless verify_only
    end

    protected
    def validate(program)
      validator = validator_for program
      validator.check!
    end

    private
    def tape
      @tape ||= Tape.new
    end

    def engine
      @engine ||= Engine.new(self)
    end

    def validator_for(program)
      Program.validator_for(program)
    end
  end
end
