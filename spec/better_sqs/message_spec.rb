require "spec_helper"

describe BetterSqs::Message do
  let(:queue_client) { mock_queue_client }
  let(:queue) { "queue_name" }
  let(:sqs_message) { mock_sqs_message }

  subject { described_class.new }

  describe "creating a new QueueMessage instance" do
    {
      queue_client: :imagine_i_am_a_queue_client,
      queue:        "queue_name",
      sqs_message:  "I like to eat peanut butter.",
    }.each do |optional_param, value|
      it "supports #{optional_param} as an optional parameter" do
        instance = described_class.new optional_param => value
        expect(instance.public_send optional_param).to eq value
      end
    end
  end

  describe "#receipt_handle" do
    it "is the s3_message's receipt handle" do
      subject.sqs_message = sqs_message
      expect(subject.receipt_handle).to eq sqs_message.receipt_handle
    end
  end

  describe "#message_body" do
    it "is the s3_message's body" do
      subject.sqs_message = sqs_message
      expect(subject.message_body).to eq sqs_message.body
    end
  end

  describe "#delete" do
    it "deletes itself from the SQS queue" do
      expect(queue_client).to receive(:delete).with(subject).and_return Aws::EmptyStructure
      subject.queue_client = queue_client

      subject.delete
    end
  end

  describe "#defer_retry" do
    it "increases the visibility timeout for the message" do
      expect(queue_client).to receive(:defer_retry).with(subject).and_return Aws::EmptyStructure
      subject.queue_client = queue_client

      subject.defer_retry
    end
  end
end
