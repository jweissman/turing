require 'spec_helper'

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

      context 'when tape is inscribed' do
        before { subject.write }
        it 'produces true' do
          expect(subject.read).to be true
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
      let(:program) do
        instance_double('Program')
      end

      let(:validator) do
        instance_spy('ProgramValidator')
      end

      it 'should check the program with the validator' do
        expect(subject).to receive(:program_validator).and_return(validator)
        subject.run!(program, verify_only: true)
        expect(validator).to have_received(:check).with(program)
      end
    end

    context 'given a coherent program known to halt by inspection' do
      before { subject.run!(program) }

      context 'which moves to another state and halts' do
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

      context 'which writes onto the tape' do
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

      context 'which writes and erases the tape' do
        let(:program) do
          Program.new do |p|
            p.state(:start) do |state|
              state.on :any, should_write: true, next_state: :one
            end
            
            p.state(:one) do |state|
              state.on :any, should_erase: true, next_state: :halt
            end
          end
        end

        it 'should halt' do
          expect(subject).to be_halted
        end

        it 'should not have an inscription on its tape' do
          expect(subject.read).to be false
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
        expect(subject.counter).to eql(Engine::EXECUTION_LIMIT)
      end
    end
  end
end
