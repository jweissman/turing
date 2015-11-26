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
      Program.new do |p|
        p.state(:start) do |start|
          start.on(:anything, transition_to: inexistent_state)
        end
      end
    end

    it 'should identify programs with invalid states' do
      expect { program.validate! }.to raise_error(expected_message)
    end
  end

  describe '#run' do
    context 'collaboration' do
      let(:program) do
        instance_double('Program', validate!: true)
      end

      it 'should check the program with its validator' do
        subject.run!(program, verify_only: true)
        expect(program).to have_received(:validate!)
      end
    end

    context 'given a coherent program known to halt by inspection' do
      before { subject.run!(program) }

      context 'which moves to another state and halts' do
        let(:program) do
          Program.new do |program|
            program.start do |s|
              s.on(:any, transition_to: :one)
            end

            program.one do |state|
              state.on :any, transition_to: :halt
            end
          end
        end

        it 'should halt' do
          expect(subject).to be_halted
        end
      end

      context 'which writes onto the tape' do
        let(:program) do
          Program.new do |p|
            p.start do |start|
              start.on :any, should_write: true, direction: :left, transition_to: :one
            end

            p.one do |one|
              one.on :any, direction: :right, transition_to: :halt
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
            p.start do |start|
              start.on :any, should_write: true, transition_to: :one
            end
            
            p.one do |one|
              one.on :any, should_erase: true, transition_to: :halt
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

      context 'which has a conditional jump' do
        let(:program) do
          Program.new do |prog|
            prog.start do |start|
              start.always should_write: true, transition_to: :one
            end

            prog.one do |one|
              one.if_symbol_present transition_to: :two
              one.if_symbol_absent  transition_to: :halt
            end

            prog.two do |two|
              two.always should_erase: true, transition_to: :one
            end
          end
        end

        it 'should halt' do
          expect(subject).to be_halted
        end
      end
    end

    context 'given a coherent program which loops forever' do
      before { subject.run!(program) }
      let(:program) do
        Program.new do |program|
          program.start do |start|
            start.on :any, transition_to: :restart
          end

          program.restart do |restart|
            restart.on :any, transition_to: :start
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
