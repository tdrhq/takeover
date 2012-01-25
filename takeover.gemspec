# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "takeover/version"

Gem::Specification.new do |s|
  s.name        = "takeover"
  s.version     = Takeover::VERSION
  s.authors     = ["Arnold Noronha"]
  s.email       = ["arnstein87@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{a simple gem that uses iptables to map a fixed ip address to an internal address, so that the internal service can be restarted with zero downtime.}
  s.description = %q{}

  s.rubyforge_project = "takeover"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
