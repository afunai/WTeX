require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name              = 'wtex'
    gem.rubyforge_project = 'wtex'
    gem.summary           = 'converts blended source written in Wiki and TeX into pure TeX or PDF'
    gem.description       = <<'_eos'
WTeX converts blended source written both in Wiki and TeX into a valid LaTeX source. Also, binary 'wikitex' will prepare templates & Makefile for making the final PDF.
_eos

    gem.authors  = ['Akira FUNAI']
    gem.email    = 'akira@funai.com'
    gem.homepage = 'http://github.com/afunai/wtex'

    gem.files = FileList[
      'bin/*',
      'lib/*.rb',
      'skel/**/*',
      't/*',
      'README*',
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
  rdoc.title = "wtex #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/*.rb')
end
