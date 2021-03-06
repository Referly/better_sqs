require "spec_helper"

describe BetterSqs::Client do
  subject { described_class.new }

  let(:queue_name) { "anotherqueue" }
  let(:queue_url) { "sqs://foo/bar" }
  let(:sqs) { mock_aws_sqs_client }
  let(:sqs_message) { mock_sqs_message }

  before do
    subject.sqs = sqs
  end

  describe "#push" do
    let(:message_body) { "I am an important message" }

    it "enqueues the message into the SQS queue" do
      expect(sqs).
        to receive(:send_message).
        with(queue_url: sqs.queues[queue_name].queue_url, message_body: message_body).
        and_return(double "SendMessageResult")

      subject.push queue_name, message_body
    end
  end

  describe "#reserve" do
    let(:receive_message_response) { mock_aws_sqs_receive_message_response messages: [sqs_message] }
    before do
      allow(sqs).to receive(:receive_message).and_return receive_message_response
    end

    it "retrieves a message from SQS" do
      expect(sqs).
        to receive(:receive_message).
        with(queue_url: sqs.queues[queue_name].queue_url, max_number_of_messages: 1).
        and_return receive_message_response

      subject.reserve queue_name
    end

    it "wraps the message in a BetterSqs::Message object" do
      expected_message = BetterSqs::Message.new queue_client: subject,
                                                queue:        queue_name,
                                                sqs_message:  sqs_message
      expect(subject.reserve queue_name).to eq expected_message
    end
  end

  describe "#delete" do
    it "deletes a message from SQS" do
      message_to_delete = BetterSqs::Message.new queue_client: subject,
                                                 queue:        queue_name,
                                                 sqs_message:  sqs_message
      expect(sqs).
        to receive(:delete_message).
        with(queue_url: sqs.queues[queue_name].queue_url, receipt_handle: sqs_message.receipt_handle)

      subject.delete message_to_delete
    end
  end

  describe "#url_for_queue" do
    let(:mock_queue) {
      mq = SqsMocks::MockQueue.new
      mq.queue_name = queue_name
      mq.queue_url = queue_url
      mq
    }
    it "creates the queue" do
      expect(sqs).to receive(:create_queue).with(queue_name: queue_name).and_return mock_queue
      subject.url_for_queue queue_name
    end

    it "is the queue_url for the queue" do
      expect(subject.url_for_queue queue_name).to eq sqs.queues.values.first.queue_url
    end
  end

  describe "#defer_retry" do
    it "increases the visibility timeout for the message" do
      message_to_defer = BetterSqs::Message.new queue_client: subject,
                                                queue:        queue_name,
                                                sqs_message:  sqs_message

      expect(sqs).
        to receive(:change_message_visibility).
        with(queue_url:          sqs.queues[queue_name].queue_url,
             receipt_handle:     message_to_defer.receipt_handle,
             visibility_timeout: BetterSqs.configuration.sqs_message_deferral_seconds)
      subject.defer_retry message_to_defer
    end
  end
end
