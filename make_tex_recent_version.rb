#!/usr/bin/env ruby

if ARGV.length != 1
  puts "Usage: ./make_tex_recent_version.rb CHAPTER"
end

Dir.chdir __dir__
desired_chapter_start = Integer ARGV[0]
tex_src = File.read 'n8440fe.tex', mode: 'rb', encoding: 'utf-8'
tex_src.gsub!(/for i=1,(\d+),1/) do
  "for i=#{desired_chapter_start},#{$1},1"
end

puts tex_src
