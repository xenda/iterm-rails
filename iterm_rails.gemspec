#!/usr/bin/env gem build
# encoding: utf-8

require "base64"

Gem::Specification.new do |s|
  s.name = "ItermRails (Go)"
  s.version = "0.0.1"
  s.authors = ["Florent Guilleux", "Alvaro Pereyra"]
  s.homepage = "http://github.com/xenda/iterm-rails"
  s.summary = "A script to launch commands in differents iTerm tabs for a Rails project"
  s.description = "#{s.summary}. inspired by http://github.com/chrisjpowers/iterm_window examples."
  s.cert_chain = nil
  s.email = Base64.decode64("YWx2YXJvQHhlbmRhY2VudHJhbC5jb20=\n")
  s.has_rdoc = false

  # files
  s.files = `git ls-files`.split("\n")

  Dir["bin/*"].map(&File.method(:basename))
  s.default_executable = "go"
  s.require_paths = ["lib"]

  # Ruby version
  s.required_ruby_version = ::Gem::Requirement.new("~> 1.9")

  begin
    require "changelog"
  rescue LoadError
    warn "You have to have changelog gem installed for post install message"
  else
    s.post_install_message = CHANGELOG.new.version_changes
  end

end
