module BetterSqs
  # A class that wraps Aws::Types::Message by reducing the size of the interface and adding imperative actions
  # like deletion of self from a queue.
  class Message
    attr_accessor :sqs_message, :queue_client, :queue

    # @param queue_client [Clients::Sqs] a SQS client instance
    # @param queue [String, Symbol] the name of the queue the message came from
    # @param sqs_message [Types::Message] the message result object
    def initialize(queue_client: nil, queue: nil, sqs_message: nil)
      @queue_client = queue_client
      @queue = queue
      @sqs_message = sqs_message
    end

    # @return [String] the receipt handle that is used to uniquely identify this particular receipt of the message
    def receipt_handle
      sqs_message.receipt_handle
    end

    # @return [String] the message's body contents
    def message_body
      sqs_message.body
    end
    alias_method :body, :message_body

    # Delete self from the SQS queue
    def delete
      BetterSqs.logger.info "Deleting message from SQS queue."
      queue_client.delete self
    end

    # Defer for sqs_message_deferral_seconds the message, before it will be made visible in sqs
    def defer_retry
      BetterSqs.logger.warn "Deferring retry processing of the message for #{BetterSqs.configuration.sqs_message_deferral_seconds} in SQS."
      queue_client.defer_retry self
    end

    def ==(other)
      sqs_message == other.sqs_message && queue_client == other.queue_client && queue == other.queue
    end
  end
end
