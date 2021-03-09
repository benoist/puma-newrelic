require 'puma/new_relic/sampler'

Puma::Plugin.create do
  def start(launcher)
    sampler = Puma::NewRelic::Sampler.new(launcher)
    launcher.events.register(:state) do |state|
      if %i[halt restart stop].include?(state)
        sampler.stop
      end
    end

    in_background do
      sampler.start
    end
  end
end
