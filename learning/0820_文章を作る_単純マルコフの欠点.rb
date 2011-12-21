# -*- coding: utf-8 -*-
# 文章を作る - 単純マルコフの欠点
# 好きなゲームの一貫性がないがないのは揺らぎなのでいいとしても、ゲームと食べ物の区別がついていない。
require File.expand_path(File.join(File.dirname(__FILE__), "markov_setup"))
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

human_messages = [
  "おもしろいゲーム教えて",
  "他におもしろいゲームある？",
  "つまらないのは？",
  "ところで主食なんだっけ？",
  ".",
]

# puts @markovs["p1_m1"].tree

human = Albatro::ActorResponder.new(:messages => human_messages)
# human = Albatro::HumanResponder.new # 自分で入力するときはここを有効にする

Chat::VipRoom.open{|room|
  room.join(SBot.new(:responder => human, :name => "おかりん"))
  room.join(SBot.new(:responder => @markovs["p1_m2"], :name => "まゆしぃ"))
  room.main_loop
}
