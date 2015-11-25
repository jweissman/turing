require 'spec_helper'

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


