require 'spec_helper'
require 'turing'

describe TapePosition do
  describe 'shift_left!' do
    it 'should decrement positional index' do
      expect { subject.shift_left! }.to change { subject.index }.by(-1)
    end
  end

  describe 'shift_right!' do
    it 'should increment positional index' do
      expect { subject.shift_right! }.to change { subject.index }.by(1)
    end
  end
end

describe Machine do
  describe 'structure' do
    it 'has a .tape' do
      expect(subject.tape).to be_a(Tape)
    end

    it 'has a .head' do
      expect(subject.head).to be_a(TapePosition)
    end
  end

  describe '#write' do
    let(:symbol) { '+' }
    it 'inscribes a symbol on the tape at head' do
      subject.write symbol
      expect(subject.read).to eql(symbol)
    end
  end

  describe '#read' do
    describe 'produces the symbol written on the tape at head' do
      context 'when tape is empty' do
        it 'produces nil' do
          expect(subject.read).to be_nil
        end
      end
    end
  end

  describe '#run' do
    context 'given a simple known-to-halt program' do
      let(:program) do
        { 
          :start      => { :any => [nil, nil, :next_state] },
          :next_state => { :any => [nil, nil, :halt] }
        }
      end

      it 'should halt' do
        subject.run!(program)
        aggregate_failures 'simple machine' do
          expect(subject.state).to eql :halt
          expect(subject.register).to all(be_empty)
        end
      end
    end

    context 'given a program which inscribes a symbol' do
      let(:program) do
        {
          :start => { :any => [ 's', :left, :next ] },
          :next  => { :any => [ nil, :right, :halt ] }
        }
      end

      it 'should have the symbol on its tape' do
        subject.run! program
        expect(subject).to be_halted
        expect(subject.read).to eq('s')
      end
    end

    context 'given a program which inscribes multiple symbols' do
      let(:program) do
        {
          :start => { :any => [ 'a', nil, :next ] },
          :next  => { :any => [ 'b', nil, :stop ] },
          :stop  => { :any => [ nil, nil, :halt ] },
        }
      end

      before { subject.run!(program) }

      it 'should have the symbol in register' do
        expect(subject).to be_halted
        expect(subject.read).to eq('b')
        expect(subject.register).to eq(['a', 'b'])
      end
    end

    context 'given a program with invalid states' do
      let(:program) do 
        {
          :start => { :any => [ nil, nil, :nonexistent ] }
        }
      end

      it 'should raise an error' do
        expect { subject.run!(program) }.to raise_error("Invalid state 'nonexistent'")
      end
    end
  end
end
