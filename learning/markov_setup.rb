# -*- coding: utf-8 -*-
# いろんな種類のマルコフたちを生成
require_relative 'helper'

@messages_hash = {
  "m1" => [
    "おもしろいゲームはドラクエです",
    "つまらないゲームはテトリスです",
  ],
  "m2" => [
    "おもしろいゲームはドラクエです",
    "つまらないゲームはテトリスです",
    "主食はスパゲティです",
  ],
}

@markovs = {}
(1..3).each{|prefix|
  @messages_hash.each{|mkey, messages|
    key = "p#{prefix}_#{mkey}"
    responder = Albatro::Responder::MarkovResponder.new(:prefix => prefix)
    messages.each{|str|responder.study_from(str)}
    if (file = Pathname("tmp/_#{File.basename(__FILE__, '.*')}_#{key}_ud.png")) && !file.exist?
      responder.to_dot(:root_label => "スタート", :file => file, :rankdir => "UD", :fontsize => 14)
      print "D"
    end
    if (file = Pathname("tmp/_#{File.basename(__FILE__, '.*')}_#{key}_lr.png")) && !file.exist?
      responder.to_dot(:root_label => "スタート", :file => file, :rankdir => "LR", :fontsize => 14)
      print "D"
    end
    @markovs[key] = responder
    print "."
  }
}
puts

if $0 == __FILE__
  p @markovs.keys
end
