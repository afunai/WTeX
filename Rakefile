require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name              = 'wikitex'
    gem.rubyforge_project = 'wikitex'
    gem.summary           = ''
    gem.description       = <<'_eos'
_eos

    gem.authors  = ['Akira FUNAI']
    gem.email    = 'akira@funai.com'
    gem.homepage = 'http://github.com/afunai/wikitex'

    gem.files = FileList[
      'bin/*',
      'lib/*.rb',
      'skel/*',
      't/*',
    ].to_a
    gem.test_files = FileList['t/test_*.rb']
    gem.executables = ['wikitex']

    gem.add_development_dependency('jeweler', '>= 1.4.0')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 't'
  test.pattern = 't/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 't'
    test.pattern = 't/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "wikitex #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/*.rb')
end
