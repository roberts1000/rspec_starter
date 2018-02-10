require "rspec_starter/version"
require_relative 'rspec_starter/runner'

module RspecStarter
  # The 'start' method takes arguments that can be used to control the steps that are executed when running Rspec.  These
  # arguments are specified by the developer when configuring how the app prefers to run RSpec.  In addition to the arguments,
  # the end user can pass command line options to the script/executable that is executing 'start'.  The command line options
  # allow the end user to customize execution on a per-run basis.  In general, the arguments have the ability to turn features
  # on and off while the command line options allow users to turn features off.  For example, a developer could probably
  # configure his aplication to always prepare the database before running RSpec.  When the command is run, the developer might
  # want to bypass preparing the database for a specific run because he already knows the database is clean (this will save some
  # startup time).  On the other hand, if the developer has configured 'start' to never prepare the database, he cannot
  # enable it via the command line on a specific run.
  #
  # Arguments List
  #   defaults(Hash)
  #     :prepare_db  => (true/false)     Should the database be rebuilt?
  #     :remove_tmp  => (true/false)     Should the tmp folder inside the application be removed before starting RSpec?
  #     :allow_xvfb  => (true/false)     Should XVFB be allowed on systems that need it (like Linux)
  #
  # Command Line Options
  #   --no-xvfb         Do not attempt to start XVFB on Linux.  On Macs, this doesn't do anything since XVFB doesn't exist.
  #   --no-prep-db      Do not try to rebuild the database.  This is useful when the db is already clean and want to save time.
  #   --no-remove-tmp   Do not attempt to remove the tmp folder.
  def self.start(defaults={})
    Runner.new(defaults).run
  end
end
