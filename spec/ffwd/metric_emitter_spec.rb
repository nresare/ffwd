require 'ffwd/metric_emitter'

describe FFWD::MetricEmitter do
  let(:output) {double}
  let(:host) {double}
  let(:tags) {double}
  let(:attributes) {double}

  let(:c) do
    described_class.new output, host, tags, attributes
  end

  let(:now) do
    double
  end

  let(:metric) do
    double
  end

  describe "#emit" do
    def make_e opts={}
      {:time => :time, :host => :host, :tags => :tags,
       :attributes => :attributes, :value => :value}.merge(opts)
    end

    before(:each) do
      expect(FFWD).to receive(:merge_hashes)
          .with(attributes, :attributes){:merged_hashes}
      expect(FFWD).to receive(:merge_sets)
          .with(tags, :tags){:merged_sets}
    end

    it "#emit should output metric" do
      expect(FFWD::Metric).to receive(:make){metric}
      expect(output).to receive(:metric).with(metric)
      c.emit make_e
    end

    it "#emit should fix NaN value in metrics" do
      expect(FFWD::Metric).to receive(:make).with(
        :tags=>:merged_sets, :attributes=>:merged_hashes, :value => nil,
        :time => :time, :host => :host){metric}
      expect(output).to receive(:metric).with(metric)
      c.emit make_e(:value => Float::NAN)
    end
  end
end
