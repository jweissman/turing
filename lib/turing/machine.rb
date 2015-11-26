module Turing
  class Machine
    extend Forwardable

    def_delegator :program_validator, :check, :validate

    def_delegators :tape, :read, :write, :erase, :move
    def_delegators :engine, :halted?, :counter, :execute

    def run!(program, verify_only: false)
      validate program
      execute program unless verify_only
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
