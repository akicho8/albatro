# -*- coding: utf-8 -*-
require "bundler/setup"
Bundler.require

responder = Albatro::MarkovResponder.new
text = "
昨日、近所の吉野家行ったんです。吉野家。
そしたらなんか人がめちゃくちゃいっぱいで座れないんです。
で、よく見たらなんか垂れ幕下がってて、150円引き、とか書いてあるんです。
もうね、アホかと。馬鹿かと。"
responder.study_from(:file => File.expand_path(File.join(File.dirname(__FILE__), "../resources/yoshinoya_2ch.txt")))
responder.study_from(:text => text)
puts responder.tree
responder.to_dot(:file => "#{File.basename(__FILE__, '.*')}.png", :root_display => false, :size => "100,100", :rankdir => "UD")
