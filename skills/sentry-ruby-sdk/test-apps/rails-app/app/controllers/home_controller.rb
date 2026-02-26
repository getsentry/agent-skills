class HomeController < ApplicationController
  def index
    # Emit simulated Sidekiq metrics so the metrics.md dashboard has data.
    # Guarded with defined?(Sentry) so the app still boots before the skill runs.
    if defined?(Sentry)
      attrs = { queue: "default", worker: "TestWorker" }
      Sentry.metrics.distribution("sidekiq.job.duration", rand(50..500),
        unit: "millisecond", attributes: attrs)
      Sentry.metrics.count("sidekiq.job.success", attributes: attrs)
      Sentry.metrics.gauge("sidekiq.queue.depth",   rand(0..10),  attributes: { queue: "default" })
      Sentry.metrics.gauge("sidekiq.queue.latency", rand(0..5).to_f,
        unit: "second", attributes: { queue: "default" })
      Sentry.metrics.gauge("sidekiq.enqueued", rand(0..20))
      Sentry.metrics.gauge("sidekiq.retries",  0)
      Sentry.metrics.gauge("sidekiq.dead",     0)
    end

    render json: { message: "Hello from TestApp", timestamp: Time.now }
  end

  def trigger_error
    raise RuntimeError, "Test error — Sentry should capture this"
  end
end
