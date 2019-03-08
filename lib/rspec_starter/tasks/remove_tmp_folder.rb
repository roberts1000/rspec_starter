# RemoveTmpFolder deletes the tmp folder before RSpec runs.
class RemoveTmpFolder < RspecStarterTask
  # Let subsequent steps run if this task runs into a problem deleting the tmp folder. This value can be overridden in
  # the applications bin/start_rspec file if the user adds 'stop_on_problem: true' to the task line.
  def self.default_stop_on_problem
    false
  end

  def starting_message
    "Removing #{'tmp'.highlight} folder"
  end

  def execute
    success "the tmp folder didn't exist" unless tmp_folder_exists?
    system "rm -rf tmp/"
    problem "the tmp folder could not be removed." if tmp_folder_exists?
  end

  private

  def tmp_folder_exists?
    File.exist?(File.join(Dir.pwd, "tmp"))
  end
end
