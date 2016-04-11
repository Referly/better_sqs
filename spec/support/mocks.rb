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

  class MockClient
    attr_accessor :queue_name, :queue_url, :current_queue

    def initialize(queue_url)
      @queue_url = queue_url
    end

    def create_queue(queue_name)
      return @current_queue if queue_name.to_s == @queue_name.to_s
      @queue_name = queue_name
      q = MockQueue.new
      q.queue_name = queue_name
      q.queue_url = queue_url
      @current_queue = q
      q
    end

    def url_for_queue(_queue_name)
      @queue_url
    end

    def send_message(queue_url: nil, message_body: nil)
      current_queue.messages << message_body
    end
  end
end

def mock_aws_sqs_client(queue_url: nil)
  SqsMocks::MockClient.new queue_url
end
