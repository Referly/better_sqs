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
    attr_accessor :queue_name, :queue_url
  end

  class MockClient
    attr_accessor :queue_name, :queue_url

    def initialize(queue_url)
      @queue_url = queue_url
    end

    def create_queue(queue_name)
      @queue_name = queue_name
      q = MockQueue.new
      q.queue_name = queue_name
      q.queue_url = queue_url
      q
    end

    def url_for_queue(_queue_name)
      @queue_url
    end
  end
end

def mock_aws_sqs_client(queue_url: nil)
  SqsMocks::MockClient.new queue_url
end
