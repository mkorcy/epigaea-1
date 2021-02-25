require 'net/smtp'

# Monitor sidekiq queue latency. Queue latency is the difference between when the
# oldest job was pushed onto the queue versus the current time. This code will
# check that jobs don't spend more than 360 seconds enqueued. We'll need to adjust
# this as we figure out what expected parameters are.
# See https://github.com/mperham/sidekiq/wiki/Monitoring#monitoring-queue-latency for general pattern.
OkComputer::Registry.register "handle_sidekiq_queue_latency", OkComputer::SidekiqLatencyCheck.new('ingest', 360)
OkComputer::Registry.register "batch_sidekiq_queue_latency", OkComputer::SidekiqLatencyCheck.new('batch', 360)
OkComputer::Registry.register "handle_sidekiq_queue_latency", OkComputer::SidekiqLatencyCheck.new('handle', 360)
OkComputer::Registry.register "default_sidekiq_queue_latency", OkComputer::SidekiqLatencyCheck.new('default', 360)

OkComputer.make_optional %w[handle_sidekiq_queue_latency batch_sidekiq_queue_latency handle_sidekiq_queue_latency default_sidekiq_queue_latency]
