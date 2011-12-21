#!/usr/local/bin/ruby -Ku

require "rubygems"
require "active_support/all"
require "kconv"
require "pathname"
require "pp"

class C
  def run(filename)
    lines = Pathname(filename).readlines
    lines = lines.reject{|line|line.match(/Auto pager|LoadPages/) || line.blank?}
    out = lines.join.gsub(/\( \d+ \)|\s+/, "\n").gsub(/\n\n+/, "\n")
    outfile = Pathname(".#{filename}.out")
    outfile.open("w"){|f|f << out}
    puts "write: #{outfile}"
  end
end

C.new.run("kami.txt")
C.new.run("hyouka.txt")
C.new.run("muda.txt")
