# -*- coding: utf-8 -*-
# 文章を作る - ぶれないマルコフ氏
# おもしろいゲームは一貫してドラクエ。テトリスではない。
require_relative 'markov_setup'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

human_messages = [
  "おもしろいゲームある？",
  "他にもおもしろいゲームある？",
  "他におもしろいのある？",
  "じゃあ、つまらないのは？",
  ".",
]

# puts @markovs["p3_m2"].tree

human = Albatro::ActorResponder.new(:messages => human_messages)
# human = Albatro::HumanResponder.new # 自分で入力するときはここを有効にする

Chat::VipRoom.open{|room|
  room.join(SBot.new(:responder => human, :name => "おかりん"))
  room.join(SBot.new(:responder => @markovs["p3_m2"], :name => "まゆしぃ"))
  room.main_loop
}
