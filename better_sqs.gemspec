Gem::Specification.new do |s|
  s.name        = "better_sqs"
  s.version     = "0.2.0"
  s.license     = "MIT"
  s.date        = "2016-04-12"
  s.summary     = "A more idiomatic interface to SQS."
  s.description = "A convenient API for developers to interact with SQS with a trivial amount of effort"
  s.authors     = ["Courtland Caldwell"]
  s.email       = "engineering@mattermark.com"
  s.files         = `git ls-files`.split("\n") - %w[Gemfile Gemfile.lock]
  s.test_files    = `git ls-files -- {spec,features}/*`.split("\n")
  s.homepage =
    "https://github.com/Referly/better_sqs"
  s.add_runtime_dependency "lincoln_logger", "~> 1.0"                   # Mattermark gem
  s.add_runtime_dependency "aws-sdk", "~> 2"                            # Apache2 https://github.com/aws/aws-sdk-ruby/blob/master/LICENSE.txt
  s.add_runtime_dependency "activesupport"
  s.add_development_dependency "rspec", "~> 3.2"                        # MIT - @link https://github.com/rspec/rspec/blob/master/License.txt
  s.add_development_dependency "byebug", "~> 3.5"                       # BSD (content is BSD) https://github.com/deivid-rodriguez/byebug/blob/master/LICENSE
  s.add_development_dependency "simplecov", "~> 0.10"                   # MIT - @link https://github.com/colszowka/simplecov/blob/master/MIT-LICENSE
  s.add_development_dependency "rubocop", "~> 0.31"                     # Create Commons Attribution-NonCommerical https://github.com/bbatsov/rubocop/blob/master/LICENSE.txt
  s.add_development_dependency "rspec_junit_formatter", "~> 0.2"        # MIT https://github.com/sj26/rspec_junit_formatter/blob/master/LICENSE
end
