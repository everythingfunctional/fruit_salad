#!/usr/bin/env ruby

require 'pathname'
require 'fileutils'

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

test_pattern = ARGV[0]

unless test_pattern
    puts "Need to provide a regular expression to specify the tests you want to run"
    exit
end

unit_test_original_files = findSourceFiles(["unit_test"], ["_test.f90"])

found_matching_test = false
unit_test_original_files.each do |filename|
    if filename =~ /#{test_pattern}/
        FileUtils.touch filename
        found_matching_test = true
    end
end

unless found_matching_test
    puts "No matching tests found"
    exit
end

unit_test_original_files.each do |filename|
    unless filename =~ /#{test_pattern}/
        new_name = filename.gsub("_test.f90", "_off.f90")
        FileUtils.mv filename, new_name
    end
end

system "rake", "unit_tests"

unit_test_original_files.each do |filename|
    unless filename =~ /#{test_pattern}/
        new_name = filename.gsub("_test.f90", "_off.f90")
        FileUtils.mv new_name, filename
    end
end

FileUtils.touch unit_test_original_files[0]
