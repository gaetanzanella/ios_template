require 'FileUtils'
require 'optparse'
require 'find'

require_relative "ios_template/CopyTemplateCommand.rb"
require_relative "ios_template/GetFrameworkNameCommand.rb"
require_relative "ios_template/RenameFilesCommand.rb"
require_relative "ios_template/InitializeGitRepositoryCommand.rb"

def systemWithoutOutput(command)
	system command, ">/dev/null 2>&1"
end

begin
	puts "Framework name ?"
	project_name = Template::GetFrameworkNameCommand.new.execute

	project_dest = Dir.pwd
	project_folder = File.expand_path("#{project_dest}/#{project_name}")

	print "\nGenerating files... "
	Template::CopyTemplateCommand.new(project_folder).execute
	Template::RenameFilesCommand.new(project_folder, project_name).execute
	puts "✅"

	print "Initializing git... "
	Template::InitializeGitRepositoryCommand.new(project_folder).execute
	puts "✅"

	puts "\nProject #{project_name} successfully bootstraped ! 🎉"
rescue  => e
	puts "\n\n🚨 Failed with error:"
	puts e.message
end