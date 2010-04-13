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
    :projects_dir           => Dir.getwd,
    :launch_server          => true,
    :launch_console         => true,
    :launch_spork_for_rspec => false,
    :launch_spork_for_cuc   => false, 
    :rails3                 => false,
    :prepend_command        => false, # example: 'rvm ruby-1.9.2-head'
  }

  def create_tab(project_path, *commands)
    project_name = project_path.basename
    open_tab :new_tab do
      write "cd #{project_path}"
      set_title "- #{project_name}"
    end
  end

  def find_available_port_from(port_number)
    result = port_number
    result += 1 while is_port_open?(result)
    result
  end

  def is_a_rails_project_directory?(project_path)
    %w{app config db script}.all? { |directory| project_path.join(directory).exist? }
  end

  # from http://stackoverflow.com/questions/517219/ruby-see-if-a-port-is-open
  def is_port_open?(port_number)
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

  def merge_configs(config, custom_config_file_path)
    if custom_config_file_path.exist?
      config.merge YAML::load(File.open custom_config_file_path) 
    else
      config
    end
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

  Tab = Struct.new :title, :commands
  tabs = []

  if config[:launch_spork_for_rspec]
    port = find_available_port_from 8989
    tabs << Tab.new("spork #{port}", ["spork -p #{port}"])
  end

  if config[:launch_spork_for_cuc]
    port = find_available_port_from 9989
    tabs << Tab.new("spork cuc #{port}", ["spork cuc -p #{port}"])
  end

  if config[:launch_console]
    command = if config[:rails3] then "rails console" else "script/console" end
    tabs << Tab.new("console", [command]) 
  end

  tabs << Tab.new("main", ["mate ./ &"])

  if config[:launch_console]
    port = find_available_port_from 3000
    command = if config[:rails3] then "rails server" else "script/server" end  
    tabs << Tab.new("server #{port}", ["#{command} -p #{port}"])
  end

  ItermWindow.open do
    project_name = project_path.basename
    tabs.each do |tab|
      open_tab :new_tab do
        write "cd #{project_path}"
        write config[:prepend_command] if config[:prepend_command]
        tab.commands.each { |command| write command }
        set_title "#{tab.title} - #{project_name}"
      end
    end
  end

end