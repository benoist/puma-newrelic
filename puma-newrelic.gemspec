require_relative 'lib/puma/new_relic/version'

Gem::Specification.new do |spec|
  spec.name    = "puma-newrelic"
  spec.version = Puma::NewRelic::VERSION
  spec.authors = ["Benoist Claassen"]
  spec.email   = ["benoist.claassen@gmail.com"]

  spec.summary               = %q{New Relic Puma Stats sampler}
  spec.description           = %q{Samples the puma stats and creates a custom metric for NewRelic}
  spec.homepage              = "https://github.com/benoist/puma-newrelic"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")
  spec.add_runtime_dependency 'puma', '>= 3.0'
  spec.add_runtime_dependency 'newrelic_rpm', '>= 6.0'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
