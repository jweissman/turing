require 'turing/version'
require 'forwardable'
require 'pry'

module Turing
  module Memory
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

    class TapePosition
      def shift(direction)
        if direction == :right
          @index = index + 1
        elsif direction == :left
          @index = index - 1
        end
      end
      
      def find(hash)
        hash[index] ||= Cell.new
      end

      protected

      def index
        @index ||= 0
      end
    end

    class Tape
      extend Forwardable
      def_delegators :current_cell, :read, :write, :erase
      def_delegator :position, :shift, :move

      def current_cell
        position.find(cells)
      end

      def position
        @position ||= TapePosition.new
      end

      def cells
        @cells ||= {}
      end
    end
  end

  module Processor
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
        @instructions.inject({}) do |hash, instruction|
          hash[instruction.symbol] = instruction
          hash
        end
      end
    end

    class ProgramValidator
      def check(program)
        instructions = program.states.collect(&:instructions).flatten
        instructions.each do |instruction|
          check_instruction instruction, program.state_names
        end
      end

      def check_instruction(instruction, state_names)
        state = instruction.next_state
        raise "Invalid state '#{state}'" unless state_names.include? state
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
      EXECUTION_LIMIT = 10_000

      attr_reader :counter

      extend Forwardable
      def_delegators :tape, :read, :write, :erase, :move

      def run!(program)
        validate program

        @state = program.find :start
        @state = iterate program until stop_iteration?
      end

      def halted?
        @state.name == :halt
      end

      protected
 
      def tape
        @tape ||= Tape.new
      end     

      def stop_iteration?
        halted? || (@counter ||= 0) >= EXECUTION_LIMIT
      end

      def validate(program)
        program_validator.check(program)
      end

      def tick!
        @counter ||= 0
        @counter += 1
      end
      
      def iterate(program)
        tick!

        instruction = next_instruction
        write if instruction.write?
        move instruction.direction if instruction.direction
        program.find instruction.next_state
      end

      protected

      def program_validator
        @validator ||= ProgramValidator.new
      end

      def next_instruction
        state_options = @state.instruction_table
        state_options[read] || state_options[:any]
      end
    end
  end
end
