# RspecStarterStep is essentially an abstract super class. It should not be instantiated directly. It primarily holds the
# logic for executing a Task or Command. Steps (and their subclasses) maintain three different types of options.
#   1. Command Options - These are specified on the command line when the bin/start_rspec command is run.
#   2. Step Options - These are specified inside the bin/start_rspec file when a task or command is added to the step list.
#   3. Step Defaults - Steps define default values when Command Options or Step Options are not given.
class RspecStarterStep
  attr_accessor :id, :exit_status, :name, :quiet, :options, :run_time, :runner, :successful

  alias_method :successful?, :successful

  def initialize(id, runner, options)
    @id = id
    initialize_name
    @runner = runner
    @options = options

    @start_time = nil
    @finish_time = nil
    @run_time = nil

    @exit_status = nil
    @successful = nil
    # This is set when the step runs
    @starting_message = nil
  end

  def self.provide_options_to(registrar)
    @options_registrar = registrar
    register_options
  end

  # Tasks can implement this method and register options that they support.
  def self.register_options
  end

  def should_skip?
    false
  end

  def quiet?
    options.quiet
  end

  def stop_on_problem?
    options.stop_on_problem
  end

  def failed?
    !@successful
  end

  def verbose?
    !quiet?
  end

  def helpers
    RspecStarter.helpers
  end

  def run
    set_starting_message
    print_starting_message
    set_start_time
    execute_step
    set_finish_time
    set_run_time
    write_run_time
    handle_step_failure
  end

  # Most subclasses will suppress output when they run.
  def self.default_quiet
    true
  end

  # Most subclasses will prefer to stop rspec_starter if they hit a problem.
  def self.default_stop_on_problem
    true
  end

  private

  # rubocop:disable Style/RescueStandardError
  # This method executes the step and ensures the output is displayed to the screen. If errors occur, it will not raise
  # an error that terminates the entire process. This method is focused on running a step, getting results and displaying output.
  # The `run` method does a final check at the end to determine if we should proceed to the next step, or raise an error
  # that terminates everything.
  def execute_step
    # Tell the step to execute. Steps should raise a 'RspecStarter::StepStopper' error by calling the 'problem' method when they
    # want to terminate the step and report a problem. Steps should raise a 'RspecStarter::StepStopper' error when they
    # want to terminate the step and report success. The code the step runs may also trigger any Ruby error. Those errors
    # are captured and are treated like a problem occured.
    execute
    # If we get here, the step didn't explicitly trigger a problem, trigger a success or raise an error.
    # Assume success and trigger it now.
    success
  rescue RspecStarter::StepStopper => e
    # If we get here, it's because the step called `problem` or `success`. Those two methods gracefully record final results
    # for the step and format a message to show the user. Since the results are already recorded, we just need to display
    # the message.
    print e.message
  rescue => e # Catch any other error
    mark_result(success: false, exit_status: 1)
    print formatted_problem_message(e.message)
  end
  # rubocop:enable Style/RescueStandardError

  def handle_step_failure
    return unless failed?

    # If the task ran quietly, give it the opportunity to write any error output it might want to show.
    write_error_info if quiet?
    raise RspecStarter::StepError if stop_on_problem?
  end

  def write_run_time
    puts " (#{run_time}s)"
  end

  def set_run_time
    @run_time = (@finish_time - @start_time).round(3)
  end

  def set_start_time
    @start_time = time_now
  end

  def set_starting_message
    @starting_message = starting_message
  end

  def set_finish_time
    @finish_time = time_now
  end

  def time_now
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def starting_message
    "Add the starting_message method to your task and say what it's doing".warning
  end

  def mark_result(success:, exit_status:)
    @successful = success
    @exit_status = exit_status
  end

  def success(msg="")
    mark_result(success: true, exit_status: 0)
    raise RspecStarter::StepStopper, formatted_success_message(msg)
  end

  def problem(details="", exact: false, exit_status: 1)
    mark_result(success: false, exit_status: exit_status)
    raise RspecStarter::StepStopper, formatted_problem_message(details, exact: exact)
  end

  def formatted_success_message(msg)
    (msg.empty? ? " Success!!" : " Success!! (#{msg})").colorize(:green)
  end

  def formatted_problem_message(details, exact: false)
    details_part = details.empty? ? "" : " (#{details})"
    msg = exact ? details : " #{problem_msg_label}#{details_part}"
    msg.colorize(problem_msg_color)
  end

  def problem_msg_label
    stop_on_problem? ? "Failed" : "Warning"
  end

  def problem_msg_color
    stop_on_problem? ? :red : :yellow
  end

  # Do nothing by default. Subclasses will implement this method if they want to display error info.
  # This method is only called in certain situations.
  def write_error_info
  end
end
