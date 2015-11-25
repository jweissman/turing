require 'spec_helper'

describe Engine do
  let(:machine) do
    instance_spy('Machine')
  end

  subject do
    Engine.new(machine)
  end

  describe '#tick!' do
    it 'should increment the counter' do
      expect { subject.tick! }.to change { subject.counter }.by(1)
    end
  end

  describe '#operate' do
    let(:program)     { instance_double('Program', find: nil) }
    let(:instruction) { instance_spy('Instruction') }

    before do
      allow(subject).to receive(:next_instruction).and_return(instruction)
      allow(subject).to receive(:stop_iteration?).and_return(false,true)
    end

    it 'should handle the instructions in the program' do
      allow(subject).to receive(:handle)
      subject.operate(program)
      expect(subject).to have_received(:handle).with(instruction)
    end
  end
end
