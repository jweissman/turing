module Turing
  class Machine
    extend Forwardable

    def_delegators :tape, :read, :write, :erase, :move
    def_delegators :engine, :halted?, :counter

    def run!(program, verify_only: false)
      validate program
      execute program unless verify_only
    end

    protected
    def execute(program)
      engine.operate(program)
    end

    def validate(program)
      program_validator.check(program)
    end

    private
    def tape
      @tape ||= Tape.new
    end     

    def engine
      @engine ||= Engine.new(self)
    end

    def program_validator
      @validator ||= ProgramValidator.new
    end
  end
end
