module Support
  module Now
    def self.included(base)
      base.let!(:now) { Time.now }
      base.before { allow(Time).to receive(:now).and_return(now) }
    end
  end
end
