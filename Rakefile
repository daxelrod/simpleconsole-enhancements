require "rake/clean"
require "rubygems"
Gem::manage_gems
require "rake/gempackagetask"

CLEAN.include("doc", "coverage")
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
