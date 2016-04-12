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

  describe "#reserve" do
    context "when there are messages in the queue to be received" do
      it "returns a message from the queue" do
        expected_message = BetterSqs::Message.new queue_client: better_client, queue: queue_name, sqs_message: encoded_message

        subject.push encoded_message

        expect(subject.reserve).to eq expected_message
      end
    end
    context "when there are no messages in the queue to be received" do
      it "is nil" do
        expect(subject.reserve).to be_nil
      end
    end
  end

  described_class::QUEUE_ATTRIBUTES.each do |queue_attribute|
    describe "##{queue_attribute}" do
      it "gets the queue attribute: '#{queue_attribute}' from SQS" do
        expect(subject.public_send queue_attribute).to eq SqsMocks::MockClient::FAUX_ATTRIBUTES[queue_attribute.to_s.camelize]
      end
    end
  end
end
