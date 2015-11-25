require 'spec_helper'
require 'turing'

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
end

describe Tape do
  describe 'structure' do
    let(:position) { subject.send :position }
    let(:cells)    { subject.send :cells }

    it 'has a position' do
      expect(position).to be_a(TapePosition)
    end

    it 'has cells' do
      expect(cells).not_to be_empty
      expect(cells).to all(be_a(Cell))
    end
  end

  # describe '#scan' do
  #   it 'reads a sequence from the tape' do
  #     subject.position.shift(:right)
  #     subject.position.shift(:right)
  #     subject.position

  #     
  #   end
  # end

  # describe '#prepare' do
  #   it 'inscribes a sequence onto the tape and rewinds it' do
  #   end
  # end
end

describe Machine do
  describe 'structure' do
    it 'has a .tape' do
      expect(subject.tape).to be_a(Tape)
    end
  end

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
    describe 'indicates whether the tape is writed at head' do
      context 'when tape is empty' do
        it 'produces false' do
          expect(subject.read).to be false
        end
      end
    end
  end
  

  describe '#run' do
    context 'given a program with invalid states' do
      let(:inexistent_state) { 'some nonexistent state' }
      let(:expected_message) { "Invalid state '#{inexistent_state}'" }

      let(:program) do 
        Program.new do |program|
          program.state(:start) do |start|
            start.on(:any, next_state: inexistent_state)
          end
        end
      end

      it 'should raise an error' do
        expect { subject.run!(program) }.to raise_error(expected_message)
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
  end
end
