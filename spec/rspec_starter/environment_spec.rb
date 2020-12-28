module RspecStarter
  RSpec.describe Environment do
    #let(:environment) { create_environment }

    context "step contexts" do
      it "equal number of steps in the start block" do
        environment = create_environment do
          command "echo 'test'"
          task :verify_display_server
          task :start_rspec
        end

        expect(environment.step_contexts.size).to be 3
      end
    end

    context "unique task clases" do
      it "foo" do
        environment = create_environment do
          command "echo 'test'"
          task :verify_display_server
          task :remove_tmp_folder
          task :rebuild_rails_app_database
          task :start_rspec
        end

        expect(environment.unique_task_classes).to eq([VerifyDisplayServer, RemoveTmpFolder, RebuildRailsAppDatabase, StartRspec])
      end
    end
  end
end
