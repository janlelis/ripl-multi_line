require 'rake'
require 'fileutils'

GEMSPEC_NAME = Dir['*.gemspec'].first

def gemspec
  @gemspec ||= eval(File.read(GEMSPEC_NAME), binding, GEMSPEC_NAME)
end

desc "Build the gem"
task :gem => :gemspec do
  sh "gem build #{GEMSPEC_NAME}"
  FileUtils.mkdir_p 'pkg'
  FileUtils.mv "#{gemspec.name}-#{gemspec.version}.gem", 'pkg'
end

desc "Install the gem locally"
task :install => :gem do
  sh %{gem install pkg/#{gemspec.name}-#{gemspec.version}.gem --no-rdoc --no-ri}
end

desc "Generate the gemspec"
task :generate do
  puts gemspec.to_ruby
end

desc "Validate the gemspec"
task :gemspec do
  gemspec.validate
end

desc 'Run tests'
task :test do |t|
  sh 'bacon -q -Ilib -I. test/*_test.rb'
end

task :default => :test
