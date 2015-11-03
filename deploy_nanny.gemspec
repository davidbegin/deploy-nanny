# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deploy_nanny/version'

Gem::Specification.new do |spec|
  spec.name          = "deploy_nanny"
  spec.version       = DeployNanny::VERSION
  spec.authors       = ["David Begin"]
  spec.email         = ["davidmichaelbe@gmail.com"]

  spec.summary       = %q{Help with keeping multiple environments up to date.}
  spec.description   = %q{Help with keeping multiple environments up to date.}
  spec.homepage      = "https://github.com/davidbegin/deploy-nanny"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_runtime_dependency "terminal-table"
  spec.add_runtime_dependency "spinning_cursor"
  spec.add_runtime_dependency "tty-progressbar"
  spec.add_runtime_dependency "colorize"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
