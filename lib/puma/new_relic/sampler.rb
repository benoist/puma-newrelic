module Puma
  module NewRelic
    class Sampler
      KEYS = %i(backlog running pool_capacity max_threads)

      def initialize(launcher, sample_rate)
        @launcher       = launcher
        @sample_rate    = sample_rate
        @last_sample_at = Time.now
      end

      def start
        @running = true
        while @running
          sleep 1
          begin
            if should_sample?
              @last_sample_at = Time.now
              puma_stats = @launcher.stats
              if puma_stats.is_a?(Hash)
                parse puma_stats
              else
                parse JSON.parse(puma_stats, symbolize_names: true)
              end
            end
          rescue Exception => e
            ::NewRelic::Agent.logger.error(e.message)
          end
        end
      end

      def should_sample?
        Time.now - @last_sample_at > @sample_rate
      end

      def stop
        @running = false
      end

      def parse(stats)
        metrics = Hash.new { |h, k| h[k] = 0 }
        sum     = ->(key, value) { metrics[key] += value if KEYS.include?(key) }

        if stats[:workers]
          metrics[:workers] = stats[:workers]
          stats[:worker_status].each do |worker|
            worker[:last_status].each(&sum)
          end
        else
          stats.each(&sum)
        end
        report_metrics(metrics)
      end

      def report_metrics(metrics)
        metrics.each do |key, value|
          ::NewRelic::Agent.logger.debug("Recorded metric: Custom/Puma/#{key}=#{value}")
          ::NewRelic::Agent.record_metric("Custom/Puma/#{key}", value)
        end
      end
    end
  end
end
