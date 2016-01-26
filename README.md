# Better SQS

Making it _easier_ for you to quickly interact with SQS in an idiomatic fashion.

## Status

[![Circle CI](https://circleci.com/gh/Referly/better_sqs.svg?style=svg)](https://circleci.com/gh/Referly/better_sqs)

## Usage

```ruby
require "better_sqs"

BetterSqs.configure

better = BetterSqs::Client.new 
better.push "better_sqs_dev_queue", "You pushed the message successfully!"
# At this point you can confirm that the message was enqueued in the AWS console
message = better.reserve "better_sqs_dev_queue"
 
puts message.message_body

message.delete
```