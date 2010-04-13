GO - Iterm-Rails
===================

A script to launch commands in differents iTerm tabs for a Rails project: console, server, mate...
inspired by http://github.com/chrisjpowers/iterm_window examples

Examples:
--------------

        iterm-rails /path/to/project
        
        iterm-rails project # you can set a default project directory (see configuration options below)


Configuration:
--------------
You can override default configuration options:

  - globally in ~/.iterm-rails.config

  - per project in project/.iterm-rails.config


Configuration options in DEFAULT_CONFIG:
----------------------------------------

        DEFAULT_CONFIG = {
          :projects_dir => Dir.getwd,
          :launch_server => true,
          :launch_console => true,
          :launch_spork_for_rspec => false,
          :launch_spork_for_cuc => false,
          :rails3 => false,
          :prepend_command => nil, # example: 'rvm ruby-1.9.2-head'
        }

Author  
------

- Florent Guilleux (Author):  github.com/Florent2 | florent2 AT gmail DOT com

- Alvaro Pereyra (Contributor):  github.com/xenda | alvaro AT xendacentral DOT com
