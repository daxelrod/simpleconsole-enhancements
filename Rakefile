require "rake/clean"
require "rubygems"
Gem::manage_gems
require "rake/gempackagetask"

CLEAN.include("doc", "coverage", "site/site", "site/doc", "pkg")
SRC = FileList['lib/*']

desc "Creates documentation for the project"
task :doc do
  sh "rdoc README MIT-LICENSE lib/* --main README"
end

desc "Runs all unit tests"
task :test do
  Dir.glob("test/test_*.rb").each do |file|
    require file
  end
end

desc "Creates the new site within the directory site/site/."
task :site => :doc do
  chdir "site"
  sh "rm -rf site" if File.exists?("site")
  sh "rm -rf doc" if File.exists?("doc")
  sh "mv ../doc ."
  sh "generate_site site"
  sh "rm -rf site/.svn" if File.exists?("site/.svn")
  sh "rm -rf site/images/.svn" if File.exists?("site/images/.svn")
  sh "rm -rf site/doc/.svn" if File.exists?("site/doc/.svn")
  chdir ".."
end

desc "Publishes the site to RubyForge."
task :publish => :site do
  chdir "site/site"
  sh "scp -r * bienhd@rubyforge.org:/var/www/gforge-projects/simpleconsole/."
  chdir "../.."
end

# needs some cleaning?
desc "Shows the total lines and LOC status"
task :stats do
  total_lines = 0
  total_codelines = 0
  files = Hash.new

  # Start with the library files
  Dir.glob("lib/*").each do |file_name| 
    lines = 0; codelines = 0

    next unless file_name =~ /.*rb/
    
    file = File.open(file_name)

    while line = file.gets
      lines += 1
      next if line =~ /^\s*$/
      next if line =~ /^\s*#/
      codelines += 1
    end

    files[File.basename(file_name)] = [lines, codelines]
    total_lines += lines
    total_codelines += codelines
  end 

  puts "+-----------------------------------+--------+--------+"
  puts "| Library File                      | Lines  | LOC    |"
  puts "+-----------------------------------+--------+--------+"
  files.each do |file_name, array| 
    print "| " + file_name + (" "*(34 - file_name.size)) + "|" 
    print " #{array[0]}" + (" "*(7 - array[0].to_s.size)) + "|"
    puts " #{array[1]}" + (" "*(7 - array[1].to_s.size)) + "|"
  end
  puts "+-----------------------------------+--------+--------+"
  print "| Total                             |"
  print " #{total_lines}" + (" "*(7 - total_lines.to_s.size)) + "|"
  puts " #{total_codelines}" + (" "*(7 - total_codelines.to_s.size)) + "|"
  puts "+-----------------------------------+--------+--------+"

  # Now do the test files
  total_lines = 0; total_codelines = 0; files = Hash.new
  Dir.glob("test/test_*").each do |file_name| 
    lines = 0; codelines = 0

    next unless file_name =~ /.*rb/
    
    file = File.open(file_name)

    while line = file.gets
      lines += 1
      next if line =~ /^\s*$/
      next if line =~ /^\s*#/
      codelines += 1
    end

    files[File.basename(file_name)] = [lines, codelines]
    total_lines += lines
    total_codelines += codelines
  end 

  puts "+-----------------------------------+--------+--------+"
  puts "| Test File                         | Lines  | LOC    |"
  puts "+-----------------------------------+--------+--------+"
  files.each do |file_name, array| 
    print "| " + file_name + (" "*(34 - file_name.size)) + "|" 
    print " #{array[0]}" + (" "*(7 - array[0].to_s.size)) + "|"
    puts " #{array[1]}" + (" "*(7 - array[1].to_s.size)) + "|"
  end
  puts "+-----------------------------------+--------+--------+"
  print "| Total                             |"
  print " #{total_lines}" + (" "*(7 - total_lines.to_s.size)) + "|"
  puts " #{total_codelines}" + (" "*(7 - total_codelines.to_s.size)) + "|"
  puts "+-----------------------------------+--------+--------+"
end

desc "Shows a quick coverage of tests."
task :rcov do 
  sh "rcov -T test/test_*.rb"
end

spec = Gem::Specification.new do |s|
  s.name = "simpleconsole"
  s.version = "0.1.0"
  s.author = "Hugh Bien"
  s.email = "bienhd@gmail.com"
  s.homepage = "http://simpleconsole.rubyforge.org"
  s.platform = Gem::Platform::RUBY
  s.summary = "Microframework for developing console apps quickly."
  s.bindir = "bin"
  s.executables = ["simcon"]
  s.default_executable = "simcon"
  s.files = FileList["{bin,bin/files,test,lib}/**"].exclude("rdoc").to_a
  s.test_files = Dir.glob('test/test_*.rb')
  s.require_path = "lib"
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "MIT-LICENSE"]
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = false
end

desc "Installs the gem in pkg/"
task :install do
  sh "sudo gem install pkg/*.gem"
end

