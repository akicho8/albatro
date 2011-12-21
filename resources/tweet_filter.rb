# -*- coding: utf-8 -*-
require "pathname"

require "rubygems"
require "active_support/all"
require "kconv"
require "pathname"
require "pp"

class C
  def run(filename)
    Pathname(filename).read.lines.each{|line|
      line = line.strip
      line = line.mb_chars.normalize.to_s
      # line = line.gsub(/　/, " ").strip
      # line = line.gsub(/(\s+\/\s+.*)/, "")
      # line = line.gsub(/\(@.*/, "")
      # end
      puts line.strip
    }
  end
end

C.new.run("famicom.txt")
