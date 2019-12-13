# RemoveTmpFolder deletes the tmp folder before RSpec runs.
class RemoveTmpFolder < RspecStarterTask
  def self.description
    "Remove the #{'tmp'.colorize(:light_blue)} folder from the project."
  end

  def self.register_options
    register_option name: "remove_dummy_tmp",
                    default: false,
                    description: "true/false to remove the tmp folder for the dummy app too."
    register_option name: "dummy_path",
                    default: "spec/dummy",
                    description: "Relative path to the dummy folder."
  end

  # Let subsequent steps run if this task runs into a problem deleting the tmp folder. This value can be overridden in
  # the applications bin/start_rspec file if the user adds 'stop_on_problem: true' to the task line.
  def self.default_stop_on_problem
    false
  end

  def starting_message
    if options.remove_dummy_tmp
      "Removing #{'tmp/'.highlight} and #{relative_dummy_tmp_folder_path.highlight} folders"
    else
      "Removing #{'tmp/'.highlight} folder"
    end
  end

  def execute
    remove_tmp_folder
    remove_dummy_tmp_folder
  end

  private

  def remove_tmp_folder
    return unless tmp_folder_exists?

    system "rm -rf tmp/"
    problem "the tmp folder could not be removed." if tmp_folder_exists?
  end

  def remove_dummy_tmp_folder
    return unless options.remove_dummy_tmp
    return unless dummy_tmp_folder_exists?

    system "rm -rf #{absolute_dummy_tmp_folder_path}"
    problem "the #{relative_dummy_tmp_folder_path} folder could not be removed." if dummy_tmp_folder_exists?
  end

  def tmp_folder_exists?
    Dir.exist?(File.join(Dir.pwd, "tmp"))
  end

  def relative_dummy_tmp_folder_path
    File.join(options.dummy_path, "tmp/")
  end

  def absolute_dummy_tmp_folder_path
    File.join(Dir.pwd, options.dummy_path, "tmp/")
  end

  def dummy_tmp_folder_exists?
    return false if options.dummy_path.nil?

    Dir.exist?(absolute_dummy_tmp_folder_path)
  end
end
