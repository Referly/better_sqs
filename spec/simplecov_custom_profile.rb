require "simplecov"
SimpleCov.profiles.define "better_sqs" do
  add_filter "/spec"
end
