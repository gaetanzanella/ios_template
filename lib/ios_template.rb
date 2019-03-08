require 'optparse'
require 'find'

options = {}

# Default value
options[:type] = :framework

OptionParser.new do |parser|
    parser.on("-t", "--type=TYPE") do |type|
      case type
      when "library", "framework"
        options[:type] = :framework
      else
        throw "Invalid argument #{type}"
      end
    end
end.parse!

name_regexp = /[A-Z][A-Za-z0-9]*/
case options[:type]
when :framework
  puts "Framework name ? (Must match #{name_regexp.inspect})"
end
project_name = gets.chomp until project_name =~ name_regexp

project_dest = Dir.pwd
project_folder = File.expand_path("#{project_dest}/#{project_name}")
puts project_folder

if File.exists?(project_folder)
  throw "Path #{project_folder} already exists"
end

case options[:type]
when :framework
  origin_template_folder = "framework"
end

puts origin_template_folder
puts project_folder

`cp -r \"./templates/#{origin_template_folder}\" \"#{project_folder}\"`

templater_folder = Dir.pwd
Dir.chdir(project_folder)

print "Renaming files... "
# We need to list all the files before renaming the files because
# Find.find doesn't like that we mess with the files that are being
# enumerated
paths = []
Find.find(".") do |path|
  paths << path
end
paths.each do |path|
  base = File.basename(path)
  new_path = path.gsub('TEMPLATE', project_name)
  new_dir, new_base = File.split(new_path)
  next unless base =~ /(TEMPLATE|TP)/
  File.rename(File.join(new_dir, base), new_path)
end
puts "✅"

print "Initializing git..."
`git init .`
`git commit -m 'Initial commit' --allow-empty`
`git checkout -b develop`
`git add .`
`git commit -m 'Initial import'`
puts "✅"

puts "🎉 Project successfully bootstraped !"
`open \"#{project_folder}\"`
