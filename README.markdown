GO - Iterm-Rails
===================

A script to launch commands in different iTerm tabs for a Rails project: console, server, mate...
inspired by http://github.com/chrisjpowers/iterm_window examples

Examples:
--------------

        iterm-rails /path/to/project
        
        iterm-rails project # you can set a default project directory (see :projects_dir configuration entry below)


Configuration:
--------------
You can override the default configuration:

  - globally in `~/.iterm-rails.config`

  - per project in `project/.iterm-rails.config`

Any entry in the configuration file creates a new tab titled with the entry key and executing the given command, except for the following special configuration entries:

* `:projects_dir` defines the default project directory where Iterm-Rails looks for project directory when given a relative path
* `:prepend_command` defines the first command to be executed in each tab, for example `:prepend_command  => 'rvm ruby-1.9.2-head'`
* `:skip_{entry_key}` will skip the name entry command, for example `:skip_console => true` will prevent the launch of the corresponding `:console` tab

`:main` tab will get the focus.

### specifying ports in commands

You can write commands that will use the first available port from a given port number with the `{{port:initial_port_number}}` syntax. For example `script/server -p {{port:3000}}` will launch a server on the first available port from 3000. This allows you to launch iterm-rails for various projects that will automatically use different ports.

### default configuration:

        DEFAULT_CONFIG = {
          :projects_dir     => Dir.getwd,
          :prepend_command  => false, # example: 'rvm ruby-1.9.2-head'
          :main             => "mate .; git st",
          :server           => "script/server -p {{port:3000}}",
          :console          => "script/console",    
          :spork_rspec      => "spork -p {{port:8989}}",
          :spork_cuc        => "spork cuc -p {{port:9989}}",    
        }

Author  
------

- Florent Guilleux (Author):  github.com/Florent2 | florent2 AT gmail DOT com

- Alvaro Pereyra (Contributor):  github.com/xenda | alvaro AT xendacentral DOT com
