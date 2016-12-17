require "aws-sdk"
module BetterSqs
  # A class that wraps the aws sdk v2 SQS client to reduce interface complexity
  class Client
    attr_accessor :sqs

    def initialize
      # if BetterSqs has not been configured then run the default configuration
      BetterSqs.configure unless BetterSqs.configured?
    end

    # Push a message onto a queue
    #
    # @param queue_name [String, Symbol] the name of the queue that the message should pushed onto
    # @param message_body [String] the message as it will be pushed onto the queue, no serialization occurs as
    #  part of this method. You need to encode or serialize your object to a string before sending it to this method
    # @param deduplication_id [String] if you are using FIFO queue mode and you are not using content based
    #  deduplication, then you'll need to set this value so that if you message is enqueued more than once
    #  SQS can prevent the duplicates from being delivered for the duration of the deduplication period
    # @param group_id [String] if you are using FIFO queue mode you need to specify a group id; for a given
    #  group_id all messages will be received in order, if you are using multiple consumers and only need
    #  ordering within a subset of your data you can use more than one group_id for the queue and then
    #  order is guaranteed only for a particular grouping
    # @return [Types::SendMessageResult] the sent message object returned from s3
    def push(queue_name, message_body, deduplication_id: nil, group_id: nil)
      opts = {
        queue_url:    url_for_queue(queue_name),
        message_body: message_body,
      }
      opts[:message_deduplication_id] = deduplication_id if deduplication_id
      opts[:message_group_id] = group_id if group_id
      sqs.send_message opts
    end

    # Reserve a message from the specified queue
    #
    # @param queue_name [String, Symbol] the name of the SQS queue to reserve a message from
    # @return [Messages::Sqs, NilClass] the message retrieved from the queue
    def reserve(queue_name)
      resp = sqs.receive_message queue_url:              url_for_queue(queue_name),
                                 max_number_of_messages: 1,
                                 attribute_names:        ["All"]
      return nil unless resp.messages.any?
      Message.new queue_client: self, queue: queue_name, sqs_message: resp.messages.first
    end

    # Delete a message from the queue
    #
    # @param message [Messages::Sqs] the message that should be deleted
    def delete(message)
      sqs.delete_message queue_url: url_for_queue(message.queue), receipt_handle: message.receipt_handle
    end

    # Updates the message visibility timeout to create some delay before an attempt will be made to reprocess the
    #  message
    #
    # @param message [Messages::Sqs] the message for which the next retry should be delayed
    def defer_retry(message)
      sqs.change_message_visibility queue_url:          url_for_queue(message.queue),
                                    receipt_handle:     message.receipt_handle,
                                    visibility_timeout: BetterSqs.configuration.sqs_message_deferral_seconds
    end

    # Get the existing or create a new instances of the SQS client
    #
    # @return [Aws::SQS::Client] an instance of the SQS client
    def sqs
      @sqs ||= Aws::SQS::Client.new
    end

    # Get the specified queue instance if it already exists, otherwise create it and wait for it to be readied
    #
    # @param queue_name [String, Symbol] the name of the queue to be created
    # @return [AWS::SQS::Queue] the requested queue instance
    def url_for_queue(queue_name)
      sqs.create_queue(queue_name: queue_name).queue_url
    end

    # Get a BetterSqs::Queue instance
    #
    # @param queue_name [String, Symbol] the name of the SQS queue
    # @return [BetterSqs::Queue] the requested Queue instance
    def queue(queue_name)
      Queue.new self, queue_name
    end
  end
end
