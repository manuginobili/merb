#!/usr/bin/env gem build
# -*- encoding: utf-8 -*-

# Assume a typical dev checkout to fetch the current merb-core version
require File.expand_path('../../merb-core/lib/merb-core/version', __FILE__)

# Load this library's version information
require File.expand_path('../lib/merb-exceptions/version', __FILE__)

require 'date'

Gem::Specification.new do |gem|
  gem.name        = 'merb-exceptions'
  gem.version     = Merb::Exceptions::VERSION.dup
  gem.date        = Date.today.to_s
  gem.authors     = ['Andy Kent']
  gem.email       = 'andy@new-bamboo.co.uk'
  gem.homepage    = 'http://merbivore.com/'
  gem.description = 'Merb plugin that supports exception notification'
  gem.summary     = 'Merb plugin that provides Email and web hook exceptions for Merb.'

  gem.has_rdoc = true 
  gem.require_paths = ['lib']
  gem.extra_rdoc_files = ['README.markdown', 'LICENSE', 'TODO']
  gem.files = Dir['Rakefile', '{lib,spec}/**/*', 'README*', 'LICENSE*', 'TODO*'] & `git ls-files -z`.split("\0")

  # Runtime dependencies
  gem.add_dependency 'merb-core',   "~> #{Merb::VERSION}"
  gem.add_dependency 'merb-mailer', "~> #{Merb::VERSION}"

  # Development dependencies
  gem.add_development_dependency 'rspec', '>= 1.2.9'
end
