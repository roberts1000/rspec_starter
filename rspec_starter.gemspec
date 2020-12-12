lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec_starter/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec_starter"
  spec.version       = RspecStarter::VERSION
  spec.authors       = ["Roberts"]
  spec.email         = ["roberts@corlewsolutions.com"]

  spec.summary       = "A Ruby gem that helps run RSpec in a standard manner."
  spec.description   = "A Ruby gem that helps run RSpec in a standard manner."
  spec.homepage      = "https://github.com/roberts1000/rspec_starter"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.6.0'

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "pry-byebug", "~> 3.9.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "activesupport", ">= 5.2.2"
  spec.add_dependency "colorize", "~> 0.8.1"
  spec.add_dependency "cri", "~> 2.0"
  spec.add_dependency "os", "~> 1.1.0"
end
