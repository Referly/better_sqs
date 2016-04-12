require "spec_helper"

describe BetterSqs::Queue do
  subject { described_class.new better_client, queue_name }

  let(:better_client) {
    b = BetterSqs::Client.new
    allow(b).to receive(:sqs).and_return mock_sqs
    b
  }
  let(:mock_sqs) { SqsMocks::MockClient.new }
  # let(:queue_url) { "some arn" }
  let(:queue_name) { "superdupertuberqueue" }
  let(:encoded_message) { { foo: "i am a foo" }.to_json }

  describe "#push" do
    it "pushes the encoded message onto the SQS queue" do
      subject.push encoded_message
      expect(mock_sqs.queues[queue_name].messages).to eq [encoded_message]
    end
  end
  #
  # describe "#reserve" do
  #   it "does stuff"
  # end
  #
  # described_class::QUEUE_ATTRIBUTES.each do |queue_attribute|
  #   describe "##{queue_attribute}" do
  #     it "does stuff"
  #   end
  # end
end
