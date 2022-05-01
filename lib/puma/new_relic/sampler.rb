module Puma
  module NewRelic
    class Sampler
      def initialize(launcher)
        config          = ::NewRelic::Agent.config[:puma] || {}
        @launcher       = launcher
        @sample_rate    = config.fetch("sample_rate", 15)
        @keys           = config.fetch("keys", %w(backlog running pool_capacity max_threads)).map(&:to_s)
        @last_sample_at = Time.now
      end

      def start
        @running = true
        while @running
          sleep 1
          begin
            if should_sample?
              @last_sample_at = Time.now
              puma_stats      = @launcher.stats
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

        if stats[:workers]
          metrics[:workers] = stats[:workers]
          stats[:worker_status].each do |worker|
            worker[:last_status].each { |key, value| metrics[key.to_s] += value if @keys.include?(key.to_s) }
          end
        else
          stats.each { |key, value| metrics[key.to_s] += value if @keys.include?(key.to_s) }
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
