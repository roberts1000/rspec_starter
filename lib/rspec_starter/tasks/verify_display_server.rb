# VerifyDisplayServer run tests on the display server. When feature tests run, they need a display server available to execute
# the feature tests. MacOS provides its own display server that always runs. Linux needs one installed and activated. This
# task is currently focused on the XVFB display server.
class VerifyDisplayServer < RspecStarterTask
  def self.register_options
    register_option default: false, switch: '--skip-display-server', description: "DO NOT check for a display server"
  end

  # Let subsequent steps run if this task runs into a problem checking the display server. This value can be overridden in
  # the applications bin/start_rspec file if the user adds 'stop_on_problem: true' to the task line.
  def self.default_stop_on_problem
    false
  end

  # The app's bin/start_rspec file might define this task, but the user can specific --skip-display-server at run time to
  # dynamically disable the check.
  def should_skip?
    options.skip_display_server
  end

  def starting_message
    "Verifying display server"
  end

  # rubocop:disable Style/IfUnlessModifier, Style/GuardClause
  def execute
    # Check if a Linux user is missing XVFB. XVFB is needed to run RSpec feature tests on Linux.
    if helpers.is_linux? && helpers.xvfb_not_installed?
      problem "XVFB isn't installed; feature specs will fail."
    end

    # Check if a Mac user has XVFB installed.  Macs have their own display server so xvfb is not needed. A dev might have
    # mistakenly installed it so we can check just in case..
    if helpers.is_mac? && helpers.xvfb_installed?
      problem "XVFB is installed. (It's not needed on a Mac and may cause specs to fail.)"
    end
  end
  # rubocop:enable Style/IfUnlessModifier, Style/GuardClause
end
