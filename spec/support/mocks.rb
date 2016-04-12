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
    attr_accessor :queues

    def initialize
      @queues = MockQueues.new
    end

    def create_queue(queue_name: nil)
      queues[queue_name]
    end

    def send_message(queue_url: nil, message_body: nil)
      queue = queues.select { |_queue_name, q| q.queue_url == queue_url }.values.first
      queue.messages << message_body
    end
  end
end

def mock_aws_sqs_client
  SqsMocks::MockClient.new
end
