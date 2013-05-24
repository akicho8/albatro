# -*- coding: utf-8 -*-
require "bundler/setup"
Bundler.require # !> loading in progress, circular require considered harmful - /Users/ikeda/src/albatro/lib/albatro/refer_methods.rb

markov = Albatro::MarkovResponder.new(:prefix => 2)
messages = [
  "おもしろいゲームはドラクエです",
  "つまらないゲームはテトリスです",
  "主食はスパゲティです",
]
messages.each{|str|
  markov.study_from(str)
}
puts markov.to_dot
markov.to_dot(:root_label => "スタート", :file => "#{File.basename(__FILE__, '.*')}_ud.png", :rankdir => "UD", :size => "5,30")
markov.to_dot(:root_label => "スタート", :file => "#{File.basename(__FILE__, '.*')}_lr.png", :rankdir => "LR")
