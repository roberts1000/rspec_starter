module ObjectCreation
  def create_environment(argv: [], &start_block)
    if start_block.nil?
      start_block =
        Proc.new do
          task :verify_display_server
          task :remove_tmp_folder
          task :rebuild_rails_app_database
          task :start_rspec
        end
    end

    RspecStarter::Environment.new([], &start_block)
  end
end

RSpec.configure do |c|
  c.include ObjectCreation
end
