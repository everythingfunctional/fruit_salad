#!/usr/bin/env ruby

require 'pathname'

def findSourceFiles(directories, extensions)
    sources = []
    extensions.each do |extension|
        directories.each do |directory|
            dir = Pathname(directory).cleanpath.to_s
            Dir::glob(File.join("#{dir}", "**", "*#{extension}")).each do |filename|
                sources.push(Pathname(filename).cleanpath.to_s)
            end
        end
    end
    return sources
end

def renameTestsExcept(filename, matched_tests)
    lines = []
    File.open(filename, "rb") do |f|
        f.each_line do |line|
            if line =~ /subroutine +test_[a-zA-Z0-9_]* *$/
                test_name = line[/subroutine +(test_[a-zA-Z0-9_]*) *$/,1]
                if matched_tests.include?(test_name)
                    lines << line
                else
                    lines << line.gsub(" test_", " off_")
                end
            else
                lines << line
            end
        end
    end
    open(filename, 'w') do |f|
        f.puts lines
    end
end

def unrenameTests(filename)
    lines = []
    File.open(filename, "rb") do |f|
        f.each_line do |line|
            if line =~ /subroutine +off_[a-zA-Z0-9_]* *$/
                lines << line.gsub(" off_", " test_")
            else
                lines << line
            end
        end
    end
    open(filename, 'w') do |f|
        f.puts lines
    end
end

test_pattern = ARGV[0]

unless test_pattern
    puts "Need to provide a regular expression to specify the tests you want to run"
    exit
end

unit_test_original_files = findSourceFiles(["unit_test"], ["_test.f90"])

matching_tests = Hash.new { |hash, key| hash[key] = [] }

unit_test_original_files.each do |filename|
    next unless File.file?(filename)
    File.open(filename, "rb") do |f|
        f.each_line do |line|
            if line =~ /^ *subroutine +#{test_pattern} *$/
                test_name = line[/^ *subroutine +([a-zA-Z0-9_]*) *$/,1]
                matching_tests[filename] << test_name
            end
        end
    end
end

if matching_tests.empty?
    puts "No matching tests found"
    exit
end

unit_test_original_files.each do |filename|
    if matching_tests.include?(filename)
        renameTestsExcept(filename, matching_tests[filename])
    else
        new_name = filename.gsub("_test.f90", "_off.f90")
        File.rename filename, new_name
    end
end

system "rake", "unit_tests"

unit_test_original_files.each do |filename|
    if matching_tests.include?(filename)
        unrenameTests(filename)
    else
        new_name = filename.gsub("_test.f90", "_off.f90")
        File.rename new_name, filename
    end
end
