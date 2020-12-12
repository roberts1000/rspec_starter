# Tasks are classes that implement an 'execute' method. Tasks can execute any ruby code they want inside the 'execute' method.
# Tasks are defined by listing their name inside the RspecStarter.start block:
#
#   RspecStarter.start do
#     task :verify_display_server
#     task :rebuild_rails_app_database, stop_on_problem: true
#     task :start_rspec, quiet: true
#   end
#
# Tasks accept a `quiet` option which tells the task to be more or less verbose. Tasks accept a `stop_on_problem` method
# that determines whether a problem should cause the entire start-up process to stop when the task encounters a problem.
class RspecStarterTask < RspecStarterStep
  def self.register_option(hash)
    @options_registrar.register_task_option(self, **hash)
  end

  def self.description
    ""
  end

  # Convert something like VerifyDisplayServer to :verify_display_server
  def self.name_for_class(klass)
    klass.name.underscore.to_sym
  end

  private

  def print_starting_message
    print "#{@starting_message} ..."
  end

  def initialize_name
    @name = self.class.name_for_class(self.class)
  end
end
