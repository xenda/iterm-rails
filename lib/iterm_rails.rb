#!/usr/bin/env ruby

# a script to launch commands in differents iTerm tabs for a Rails project: console, server, mate...
# inspired by http://github.com/chrisjpowers/iterm_window examples

# examples:
#  iterm-rails /path/to/project
#  iterm-rails project # you can set a default project directory (see configuration options below)

# you can override default configuration options:
#  globally in ~/.iterm-rails.config
#  per project in project/.iterm-rails.config
# see configuration options in DEFAULT_CONFIG below


require 'rubygems'
require 'iterm_window'
require 'pathname'
require 'yaml'
require 'socket'
require 'timeout'

module ItermRails

  DEFAULT_CONFIG = {
    :projects_dir     => Dir.getwd,
    :prepend_command  => false, # example: 'rvm ruby-1.9.2-head'
    :main             => "mate .; git st",
    :server           => "script/server -p {{port:3000}}",
    :console          => "script/console",    
    :spork_rspec      => "spork -p {{port:8989}}",
    :spork_cuc        => "spork cuc -p {{port:9989}}",    
  }
  NON_COMMAND_KEYS = [:projects_dir, :prepend_command]
  
  def self.find_available_port_from(port_number)
    result = port_number
    result += 1 while is_port_open?(result)
    result
  end

  def self.is_a_rails_project_directory?(project_path)
    %w{app config db script}.all? { |directory| project_path.join(directory).exist? }
  end

  # from http://stackoverflow.com/questions/517219/ruby-see-if-a-port-is-open
  def self.is_port_open?(port_number)
    begin
      Timeout::timeout(1) do
        begin
          s = TCPSocket.new('localhost', port_number)
          s.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          return false
        end
      end
    rescue Timeout::Error
    end

    return false
  end

  def self.merge_configs(config, custom_config_file_path)
    if custom_config_file_path.exist?
      config.merge YAML::load(File.open custom_config_file_path) 
    else
      config
    end
  end
  
  def self.substitute_port(string)
    string.gsub!(/\{\{port:(\d+)\}\}/) { |match| find_available_port_from $1 }
  end

  config = merge_configs DEFAULT_CONFIG, Pathname.new('~').expand_path.join('.iterm-rails.config')

  raise "missing project path" if ARGV.first.nil?
  project_path = Pathname.new ARGV.first
  project_path = Pathname.new(config[:projects_dir]).join(project_path) if project_path.relative?
  project_path = project_path.expand_path
  raise "'#{project_path}' does not exist or is not a directory" if !project_path.directory?
  raise "'#{project_path}' is not a Rails project directory" if !is_a_rails_project_directory?(project_path)
  config = merge_configs config, project_path.join('.iterm-rails.config')

  puts "open new window with tabs for '#{project_path}'"
  puts " with config: #{config.inspect}"

  ItermWindow.open do
    project_name = project_path.basename
    command_keys = config.keys - NON_COMMAND_KEYS
    command_keys.each do |command_key|
      open_tab :new_tab do
        write "cd #{project_path}"        
        write config[:prepend_command] if config[:prepend_command]
        write ItermRails.substitute_port(config[command_key])
        set_title "#{command_key} - #{project_name}"
      end
    end
  end

end