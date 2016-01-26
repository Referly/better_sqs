require "spec_helper"

describe BetterSqs do
  describe "configuring BetterSqs" do
    describe ".configure" do
      it "yields an instance of BetterSqs::Configuration to the provided configuration block" do
        expect { |b| BetterSqs.configure(&b) }.to yield_with_args BetterSqs::Configuration
      end
      describe "configurable attributes" do
        {
          queue_name: "handsomequeue",
          region:     "us-east-1",
        }.each do |k, v|
          describe "#{k}" do
            let(:key) { k }
            let(:value) { v }

            let(:configure_block) do
              proc do |config|
                config.send "#{key}=", value
              end
            end

            it "is configurable" do
              described_class.configure(&configure_block)

              expect(described_class.configuration.public_send k).to eq v
            end
          end
        end
      end
      it "allows the configuration to be reset" do
        described_class.configure do |c|
          c.queue_name = "original_queue_name"
        end
        first_configuration = described_class.configuration

        described_class.configure(reset: true) do |c|
          c.region = "ca-1"
        end

        expect(described_class.configuration).not_to eq first_configuration
        expect(described_class.configuration.queue_name).not_to eq "original_queue_name"
        expect(described_class.configuration.region).to eq "ca-1"
      end
    end
  end

  describe "accessing the current BetterSqs configuration" do
    describe ".configuration" do
      context "when the BetterSqs has been previously configured" do
        before do
          described_class.configure
        end

        it "is the current configuration of the BetterSqs" do
          expected_configuration = described_class.instance_variable_get :@configuration

          expect(described_class.configuration).to eq expected_configuration
        end
      end

      context "when the BetterSqs has not been previously configured" do
        it "sets the current configuration to a new instance of Configuration" do
          described_class.configuration

          expect(described_class.instance_variable_get :@configuration).to be_a BetterSqs::Configuration
        end

        it "returns the new Configuration instance" do
          expect(described_class.configuration).to eq described_class.instance_variable_get :@configuration
        end
      end
    end
  end
end
