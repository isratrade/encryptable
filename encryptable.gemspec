# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "encryptable/version"

Gem::Specification.new do |s|
  s.name        = "encryptable"
  s.version     = Encryptable::VERSION
  s.authors     = ["Joseph Magen"]
  s.email       = ["jmagen@redhat.com"]
  s.homepage    = ""
  s.summary     = "Easily encrypts ActiveRecord attributes for Rails 3 applications."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activerecord", ">= 3.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
end
