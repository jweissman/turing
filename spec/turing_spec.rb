require 'spec_helper'
require 'turing'

include Turing::Memory
include Turing::Processor

describe TapePosition do
  describe 'shift' do
    context ':left' do
      it 'should decrement positional index' do
        expect { subject.shift(:left) }.to change { subject.send :index }.by(-1)
      end
    end

    context ':right' do
      it 'should increment positional index' do
        expect { subject.shift(:right) }.to change { subject.send :index }.by(1)
      end
    end
  end
end

describe Cell do
  describe '#inscribed?' do
    it 'starts off false' do
      expect(subject).not_to be_inscribed
    end
  end

  describe '#write' do
    before { subject.write }
    it 'marks the cell' do
      expect(subject).to be_inscribed
    end
  end

  describe '#erase' do
    context 'when nothing has been written' do
      before { subject.erase }
      it 'unmarks the cell' do
        expect(subject).not_to be_inscribed
      end
    end

    context 'when something has been written' do
      before do 
        subject.write 
        subject.erase 
      end

      it 'unmarks the cell' do
        expect(subject).not_to be_inscribed
      end
    end
  end
end

describe Tape do
  describe 'structure' do

    it 'has a position' do
      expect(subject.position).to be_a(TapePosition)
    end

    # it 'has cells' do
    #   expect(subject.cells).not_to be_empty
    #   expect(subject.cells).to all(be_a(Cell))
    # end
  end

  describe '#current_cell' do
    it 'calls #find on position with cells' do
      position = instance_spy('TapePosition')
      expect(subject).to receive(:position).and_return(position)
      
      subject.current_cell

      expect(position).to have_received(:find).with(subject.cells)
    end
  end

  # describe '#scan' do
  #   before do
  #     subject.position.shift(:right)
  #     subject.position.shift(:right)
  #     subject.position.shift(:right)
  #     subject.write
  #     subject.position.shift(:left)
  #     subject.erase
  #     subject.position.shift(:left)
  #     subject.write
  #     subject.position.shift(:left)
  #   end

  #   it 'reads a sequence left-to-right from the tape' do
  #     expect(subject.scan).to eql([1,0,1])
  #   end
  # end

  # describe '#prepare' do
  #   it 'inscribes a sequence onto the tape and rewinds it' do
  #   end
  # end
end

describe Machine do
  describe '#write' do
    it 'writes the tape at head' do
      subject.write
      expect(subject.read).to be true
    end
  end

  describe '#erase' do
    before { subject.write }
    it 'erases an inscription at head' do
      subject.erase
      expect(subject.read).to be false
    end
  end

  describe '#read' do
    describe 'indicates whether the tape is inscribed at head' do
      context 'when tape is empty' do
        it 'produces false' do
          expect(subject.read).to be false
        end
      end
    end
  end
  
  describe '#validate' do
    let(:inexistent_state) { 'some nonexistent state' }
    let(:expected_message) { "Invalid state '#{inexistent_state}'" }

    let(:program) do 
      Program.new do |program|
        program.state(:start) do |start|
          start.on(:any, next_state: inexistent_state)
        end
      end
    end

    it 'should identify programs with invalid states' do
      expect { subject.validate(program) }.to raise_error(expected_message)
    end
  end

  describe '#run' do
    context 'collaboration' do
      let(:instruction) do
        instance_double('Instruction', write?: false, direction: nil, next_state: :halt)
      end

      let(:start) do
        instance_double('State', name: :start, instruction_table: {
          any: instruction
        })
      end

      let(:program) do
        instance_double('Program', find: start)
      end

      let(:validator) do
        instance_spy('ProgramValidator')
      end

      it 'should check the program with the validator' do
        expect(subject).to receive(:program_validator).and_return(validator)
        subject.run!(program)
        expect(validator).to have_received(:check).with(program)
      end
    end

    context 'given coherent programs known to halt by inspection' do
      before { subject.run!(program) }

      context 'given a simple program' do
        let(:program) do
          Program.new do |program|
            program.state(:start) do |s|
              s.on(:any, next_state: :one)
            end

            program.state(:one) do |state|
              state.on :any, next_state: :halt
            end
          end
        end

        it 'should halt' do
          expect(subject).to be_halted
        end
      end

      context 'given a program which writes a symbol' do
        let(:program) do
          Program.new do |program|
            program.state :start do |start|
              start.on :any, should_write: true, direction: :left, next_state: :one
            end

            program.state :one do |one|
              one.on :any, direction: :right, next_state: :halt
            end
          end
        end

        it 'should halt' do
          expect(subject).to be_halted
        end

        it 'should have an inscription on its tape' do
          expect(subject.read).to be true
        end
      end
    end

    context 'given a coherent program which loops forever' do
      before { subject.run!(program) }
      let(:program) do
        Program.new do |program|
          program.state :start do |start|
            start.on :any, next_state: :restart
          end

          program.state :restart do |state|
            state.on :any, next_state: :start
          end
        end
      end

      it 'should not halt' do
        expect(subject).not_to be_halted
      end

      it 'should have maxed out the step counter' do
        expect(subject.counter).to eql(Machine::EXECUTION_LIMIT)
      end
    end
  end
end
