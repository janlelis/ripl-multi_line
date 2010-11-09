# -*- encoding: utf-8 -*-
require 'rubygems' unless Object.const_defined?(:Gem)
require File.dirname(__FILE__) + "/lib/ripl/multi_line"
 
Gem::Specification.new do |s|
  s.name        = "ripl-multi_line"
  s.version     = Ripl::MultiLine::VERSION
  s.authors     = ["Jan Lelis"]
  s.email       = "mail@janlelis.de"
  s.homepage    = "http://github.com/janlelis/ripl-multi_line"
  s.summary = "A ripl plugin for multi-line eval."
  s.description =  "This ripl plugin allows you to evaluate multiple lines of Ruby code."
  s.required_rubygems_version = ">= 1.3.6"
  s.add_dependency 'ripl', '>= 0.2.0'
  s.files = Dir.glob(%w[{lib,test}/**/*.rb bin/* [A-Z]*.{txt,rdoc} ext/**/*.{rb,c} **/deps.rip]) + %w{Rakefile .gemspec}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
  s.license = 'MIT'
end
