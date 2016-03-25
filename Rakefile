require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rubygems/package_task'
require 'rdoc/task'
require 'rspec/core/rake_task'

spec = Gem::Specification.new do |s|
  s.name = 'first_logic_template'
  s.version = '4.0.0'
  s.has_rdoc = true
  s.extra_rdoc_files = ['readme.md', 'LICENSE']
  s.summary = 'FirstLogic Template Handler'
  s.description = s.summary
  s.author = 'Don V Nielsen'
  s.email = 'dnielsen@merkleinc.com'
  # s.executables = ['your_executable_here']
  s.files = %w(LICENSE readme.md Rakefile) + Dir.glob("{lib,spec,setups}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end

Gem::PackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

Rake::RDocTask.new do |rdoc|
  files =['readme.md', 'LICENSE', 'lib/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "readme.md"                     # page to start on
  rdoc.title = "FirstLogic Template Docs"
  rdoc.rdoc_dir = 'doc/rdoc'               # rdoc output folder
  rdoc.options << '--line-numbers'
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['-c','-fd']
end

RSpec::Core::RakeTask.new(:coverage) do |t|
  t.rcov = true
  t.verbose = true
end

