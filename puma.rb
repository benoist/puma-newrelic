require  "newrelic_rpm"
require_relative "./lib/puma/plugin/new_relic_stats"
plugin 'new_relic_stats'
