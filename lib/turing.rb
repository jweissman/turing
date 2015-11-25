require 'turing/version'

module Turing
  class TapePosition
    def shift_right!
      @index += 1
      self
    end

    def shift_left!
      @index -= 1
      self
    end

    # protected

    def index
      @index ||= 0
    end

  end

  class Tape
    def inscribe(symbol)
      cells[position.index] = symbol
    end

    def read_inscription
      cells[position.index] ||= nil
    end

    def position
      @position ||= TapePosition.new
    end

    def cells
      @cells ||= []
    end
  end

  class Machine
    attr_reader :tape

    def initialize
      @tape = Tape.new
    end

    def head
      @tape.position
    end

    def write(sym)
      @tape.inscribe sym
    end

    def read
      @tape.read_inscription
    end

    def run!(program)
      iterate program until halted?
    end
    
    def iterate(program)
      raise "Invalid state '#{state}'" unless program.include?(state)

      state_options = program[state]

      register.push(read)
      register.compact!

      symbol, direction, @state = state_options[read] || state_options[:any]

      write(symbol) if symbol
      @tape.position.send :"shift_#{direction}!" if direction
    end

    def register
      @registry ||= []
    end

    def state
      @state ||= :start
    end

    def halted?
      @state == :halt
    end
  end
end
