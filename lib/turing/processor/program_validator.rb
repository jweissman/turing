module Turing
  module Processor
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
  end
end

