require "securerandom"

def mock_queue_client
  double "QueueClient"
end

def mock_sqs_message
  double "SqsMessage", receipt_handle: "0111532-2342124", body: "this is the body of the message"
end

def mock_aws_sqs_receive_message_response(messages: [])
  double "ReceiveMessageResponse", messages: messages
end

module SqsMocks
  class MockQueue
    attr_accessor :queue_name, :queue_url, :messages

    def initialize
      @messages = []
    end
  end

  class MockQueues < Hash
    def [](key)
      existing_val = super
      return existing_val if existing_val
      self[key] = create_queue queue_name: key
    end

    def create_queue(queue_name: nil)
      q = MockQueue.new
      q.queue_name = queue_name
      queue_url = SecureRandom.hex(10)
      q.queue_url = queue_url
      q
    end
  end

  class MockClient
    FAUX_ATTRIBUTES = {
      "ApproximateNumberOfMessages"           => 5,
      "ApproximateNumberOfMessagesNotVisible" => 2,
      "VisibilityTimeout"                     => 10,
      "CreatedTimestamp"                      => 123_456,
      "LastModifiedTimestamp"                 => 123_456,
      "Policy"                                => :some_policy,
      "MaximumMessageSize"                    => 256_000,
      "MessageRetentionPeriod"                => 86_400,
      "QueueArn"                              => "arn:aws:sqs:us-east-1:201024061765:dolla-custom_list_creation_delete_user_tag_lots",
      "ApproximateNumberOfMessagesDelayed"    => 3,
      "DelaySeconds"                          => 12,
      "ReceiveMessageWaitTimeSeconds"         => 25,
      "RedrivePolicy"                         => :redrive_policy,
    }
    attr_accessor :queues

    def initialize
      @queues = MockQueues.new
    end

    def create_queue(queue_name: nil)
      queues[queue_name]
    end

    def send_message(queue_url: nil, message_body: nil)
      queue = queue_by_url queue_url
      queue.messages << message_body
    end

    # If we get to the point of needing to mock visiblity then this approximation will not be adequate
    def receive_message(queue_url: nil, max_number_of_messages: nil)
      queue = queue_by_url queue_url
      r = MockResponse.new
      r.messages = Array(queue.messages.shift max_number_of_messages) if queue.messages.any?
      r
    end

    # Just a static mock of the get_queue_attributes API
    def get_queue_attributes(queue_url: nil, attribute_names: nil)
      r = MockResponse.new
      if attribute_names == "All"
        r.attributes = FAUX_ATTRIBUTES
      else
        attribute_names.each do |attribute_name|
          r.attributes[attribute_name] = FAUX_ATTRIBUTES[attribute_name]
        end
      end
      r
    end

    private

    def queue_by_url(queue_url)
      queues.select { |_queue_name, q| q.queue_url == queue_url }.values.first
    end
  end

  class MockResponse
    attr_accessor :messages, :attributes

    def initialize
      @messages = []
      @attributes = {}
    end
  end
end

def mock_aws_sqs_client
  SqsMocks::MockClient.new
end
