require 'turing/version'
require 'forwardable'
require 'pry'

module Turing
  class TapePosition
    def shift(direction)
      if direction == :right
        @index += 1
      elsif direction == :left
        @index -= 1
      end
    end
    
    def find(list)
      list[index]
    end

    protected

    def index
      @index ||= 0
    end
  end

  class Cell
    def read
      inscribed?
    end

    def write
      @inscribed = true
    end

    def erase
      @inscribed = false
    end

    def inscribed?
      @inscribed ||= false
    end
  end

  class Tape
    extend Forwardable
    def_delegators :current_cell, :read, :write, :erase
    def_delegator :position, :shift, :move

    def current_cell
      position.find(cells)
    end

    protected

    def position
      @position ||= TapePosition.new
    end

    def cells
      @cells ||= [Cell.new]
    end
  end

  class Instruction
    attr_reader :symbol
    attr_reader :next_state, :should_write, :direction

    def initialize(symbol, should_write: nil, direction: nil, next_state: :halt)
      @symbol = symbol
      @should_write = should_write
      @direction = direction
      @next_state = next_state
    end

    def write?
      !!should_write
    end
  end

  class State
    attr_reader :name, :instructions

    def initialize(name)
      @name = name
      @instructions = []
      yield self if block_given?
    end

    def on(sym, *opts)
      @instructions << Instruction.new(sym, *opts)
      self
    end

    def instruction_table
      table = {}
      @instructions.each do |instruction|
        table[instruction.symbol] = instruction
      end
      table
    end
  end

  class ProgramValidator
    def check(program)
      state_names = program.state_names
      program.states.each do |state|
        state.instructions.each do |instruction|
          unless state_names.include?(instruction.next_state)
            raise "Invalid state '#{instruction.next_state}'" 
          end
        end
      end
    end
  end

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

  class Machine
    extend Forwardable
    def_delegators :tape, :read, :write, :erase, :move

    def tape
      @tape ||= Tape.new
    end

    def run!(program)
      @state = program.find :start
      @state = iterate program until halted?
    end

    def validate(program)
      program_validator.check(program)
    end
    
    def iterate(program)
      instruction = next_instruction
      write if instruction.write?
      move instruction.direction if instruction.direction
      program.find instruction.next_state
    end

    def halted?
      @state.name == :halt
    end

    protected

    def next_instruction
      state_options = @state.instruction_table
      state_options[read] || state_options[:any]
    end
  end
end
