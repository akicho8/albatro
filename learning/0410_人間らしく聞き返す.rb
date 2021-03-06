# -*- coding: utf-8 -*-
# 相手の発言を疑問で返してくる1(アホ)
require_relative 'helper'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

messages = [
  "儚い花が散る",
  "大切な人はもういない",
  "最近、大規模なデータを処理する技術が注目を集めています。",
  ".",
]
messages.each{|message|
  # Albatro::Morpheme.instance.analyze_display(message)
}

human = Albatro::Responder::ActorResponder.new(:messages => messages)
# human = Albatro::Responder::HumanResponder.new # 自分で入力するときはここを有効にする

Chat::VipRoom.open{|room|
  room.join(SBot.new(:responder => human, :name => "おかりん"))
  room.join(SBot.new(:responder => Albatro::Responder::AskResponder.new, :name => "まゆしぃ"))
  room.main_loop
}
