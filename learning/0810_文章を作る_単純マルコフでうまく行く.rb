# -*- coding: utf-8 -*-
# 文章を作る - 単純マルコフでうまく行く
# 文章になっている
require_relative 'markov_setup'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

human_messages = [
  "おもしろいゲーム教えて",
  "他にもおもしろいゲームある？",
  "つまらないゲームは？",
  "さっきおもしろいゲームはドラクエって言わなかった？",
  "それはさっき聞いたな",
  ".",
]

human = Albatro::Responder::ActorResponder.new(:messages => human_messages)
# human = Albatro::Responder::HumanResponder.new # 自分で入力するときはここを有効にする

Chat::VipRoom.open{|room|
  room.join(SBot.new(:responder => human, :name => "おかりん"))
  room.join(SBot.new(:responder => @markovs["p1_m1"], :name => "まゆしぃ"))
  room.main_loop
}
