module RspecStarter
  # The step that makes sure XVFB is installed on the system.  When feature tests run, they need a display server to power the
  # browsr that will execute the feature tests.  MacOS provides its own display server that always runs.  Linux needs one
  # installed and activated.
  class VerifyXvfbStep < RspecStarter::Step
    def initialize(defaults, runner)
      super(runner)
      @relevant_options << '--no-xvfb'
      @use_xvfb = defaults.fetch(:use_xvfb, true)
      @user_wants_to_skip_xvfb = ARGV.any? { |option| option.include?("--no-xvfb") }
    end

    # This step doesn't really fail.  Although there may be problems with how XVFB is installed, it's only a problem when the
    # user is trying to run feature specs.  The user may be in a situation where he's working on Linux and XVFB isn't installed,
    # but he may not have any feature specs to run.  We shouldn't block the tests from running just because XVFB hasn't been
    # installed yet.  So we just warn the user and put the ball in his court.  If he's running feature specs with a busted
    # XVFB setup, we have at least warned him.
    def failed?
      false
    end

    def should_execute?
      return false if @user_wants_to_skip_xvfb
      @use_xvfb
    end

    # There are two cases we need to be checked
    #   1. A Linux user does not have xvfb installed (xvfb is needed to run RSpec feature tests on Linux).
    #   2. A Mac User has xvfb installed.   (Macs have their own display server so xvfb is not needed; a dev might have mistakenly
    #      tried to install, so we can check for it just in case.)
    def execute
      return if should_skip?

      print "[#{@runner.step_num}] Verifying display server ... "

      if @runner.is_linux? && !@runner.xvfb_installed?
        return puts "Warning (XVFB is not installed.  Feature specs will fail.)".colorize(:yellow)
      end

      if @runner.is_mac? && @runner.xvfb_installed?
        return puts "Warning (XVFB has been installed.  It's not needed on a Mac and may cause specs to fail.)".colorize(:yellow)
      end

      puts "Success!!".colorize(:green)
    end
  end
end
