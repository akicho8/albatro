# -*- coding: utf-8 -*-
# 文章を作る - もう単純とは言わせない
# 好きなゲームの一貫性がないが、ゲームと食べ物の区別ができるようになる
require_relative 'markov_setup'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

human_messages = [
  "おもしろいゲーム教えて",
  "他におもしろいゲームある？",
  "つまらないのは？",
  "ところで主食なんだっけ？",
  ".",
]

human = Albatro::ActorResponder.new(:messages => human_messages)
# human = Albatro::HumanResponder.new # 自分で入力するときはここを有効にする

Chat::VipRoom.open{|room|
  room.join(SBot.new(:responder => human, :name => "おかりん"))
  room.join(SBot.new(:responder => @markovs["p2_m2"], :name => "まゆしぃ"))
  room.main_loop
}
