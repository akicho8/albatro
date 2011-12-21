# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "../lib/albatro"))

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
