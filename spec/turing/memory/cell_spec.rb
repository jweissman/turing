require 'spec_helper'

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

