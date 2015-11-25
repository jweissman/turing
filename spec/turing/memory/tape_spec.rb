require 'spec_helper'

describe Tape do
  describe 'structure' do
    it 'has a position' do
      expect(subject.position).to be_a(TapePosition)
    end
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

