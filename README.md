# Better SQS

Making it _easier_ for you to quickly interact with SQS in an idiomatic fashion.

## Status

[![Circle CI](https://circleci.com/gh/Referly/better_sqs.svg?style=svg)](https://circleci.com/gh/Referly/better_sqs)

## Usage

```ruby
require "better_sqs"

better = BetterSqs::Client.new 
better.push "better_sqs_dev_queue", "You pushed the message successfully!"
# At this point you can confirm that the message was enqueued in the AWS console
message = better.reserve "better_sqs_dev_queue"
 
puts message.message_body

message.delete
```

If you prefer you can interact with a Queue directly for enqueue and dequeue operations

```ruby
require "better_sqs"

better = BetterSqs::Client.new
queue = better.queue "better_sqs_dev_queue"
queue.push "You pushed the message successfully!"
message = queue.reserve

puts message.message_body
message.delete
```

### Inspecting a queue

BetterSqs makes it easy to check on the attributes of a SQS queue.

```ruby
require "better_sqs"

better = BetterSqs::Client.new
queue = better.queue("better_sqs_dev_queue")
queue.approximate_number_of_messages
queue.approximate_number_of_messages_not_visible
queue.visibility_timeout
queue.created_timestamp
queue.last_modified_timestamp
queue.policy
queue.maximum_message_size
queue.message_retention_period
queue.queue_arn
queue.approximate_number_of_messages_delayed
queue.delay_seconds
queue.receive_message_wait_time_seconds
queue.redrive_policy
```

## Configuration

To configure BetterSqs use the configuration block pattern

```ruby
require "better_sqs"
BetterSqs.configure do |config|
    # When a message is deferred, this number of seconds is added to the time period that the message
    # will remain invisible to other consumers. SQS has a hard cap of 12 hours on visibility.
    # It defaults to 60 seconds
    config.sqs_message_deferral_seconds = 120
    
    # If you want to hardcode which region of SQS should be used then you can set this option. It is recommended
    # to use the environment variable ENV["AWS_REGION"] instead
    config.region = "us-west-2"
    
    # for aws_access_key_id and aws_secret_access_key you can set them in this fashion, but it is strongly
    # recommended that you just use the environment variables instead: ENV["AWS_ACCESS_KEY_ID"], 
    # ENV["AWS_SECRET_ACCESS_KEY"]
end
```