require 'oyster_card'

describe Oystercard do

  let(:entry_station) { double :entry_station }
  let(:exit_station) { double :exit_station }

  describe '#balance' do
    it { is_expected.to respond_to :balance }

    it "returns a starting balance of 0" do
      expect(subject.balance).to eq 0
    end
  end

  describe '#top_up' do
    it { is_expected.to respond_to(:top_up).with(1).argument }

    it 'tops up card balance using passed argument as value' do
      subject.top_up(80)
      expect(subject.balance).to eq 80
    end

    it 'raises an error when balance is over maximum limit' do
      subject.top_up(Oystercard::MAX_BALANCE)
      expect { subject.top_up(1) }.to raise_error "Maximum balance of £#{Oystercard::MAX_BALANCE} has been exceeded"
    end
  end

  #describe '#deduct' do
  #  it { is_expected.to respond_to(:deduct).with(1).argument }

  #  it 'deducts card balance using passed argument as value' do
  #    subject.top_up(80)
  #    subject.deduct(20)
  #    expect(subject.balance).to eq 60
  #  end
  #end

  describe '#in_journey?' do
    it "does not start in a journey" do
      expect(subject).not_to be_in_journey
    end
  end

  describe '#touch_in' do
    it { is_expected.to respond_to(:touch_in).with(1).argument }

    it "sets the card to be in journey" do
      subject.top_up(Oystercard::MIN_BALANCE)
      subject.touch_in(entry_station)
      expect(subject).to be_in_journey
    end

    it "raises an error when trying to touch in with a balance of less than 1" do
      expect{ subject.touch_in(entry_station) }.to raise_error "Balance is bellow minimum threshold"
    end

    it "remembers the current entry station" do
      subject.top_up(Oystercard::MIN_BALANCE)
      subject.touch_in(entry_station)
      expect(subject.entry_station).to eq entry_station
    end
  end

  describe '#touch_out' do
    it { is_expected.to respond_to(:touch_out).with(1).argument }

    it "sets the card to not be in journey" do
      subject.top_up(Oystercard::MIN_BALANCE)
      subject.touch_in(entry_station)
      subject.touch_out(exit_station)
      expect(subject).not_to be_in_journey
    end

    it "deducts fare when touching out" do
      expect { subject.touch_out(exit_station) }.to change{ subject.balance }.by (- Oystercard::MIN_BALANCE)
    end

    it "remembers the current exit station" do
      subject.top_up(Oystercard::MIN_BALANCE)
      subject.touch_in(entry_station)
      subject.touch_out(exit_station)
      expect(subject.exit_station).to eq exit_station
    end
  end

  describe '#journey' do
    it "returns the entry and exit stations of a journey" do
      subject.top_up(Oystercard::MIN_BALANCE)
      subject.touch_in(entry_station)
      subject.touch_out(exit_station)
      expect(subject.journey).to eq({ entry_station => exit_station })
    end

      it "checks that card has empty list of journeys by default" do
        expect(subject.journey).to be_empty
      end

  end

end
