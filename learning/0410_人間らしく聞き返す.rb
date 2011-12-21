# -*- coding: utf-8 -*-
# 相手の発言を疑問で返してくる1(アホ)
require File.expand_path(File.join(File.dirname(__FILE__), "helper"))
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

human = Albatro::ActorResponder.new(:messages => messages)
# human = Albatro::HumanResponder.new # 自分で入力するときはここを有効にする

Chat::VipRoom.open{|room|
  room.join(SBot.new(:responder => human, :name => "おかりん"))
  room.join(SBot.new(:responder => Albatro::AskResponder.new, :name => "まゆしぃ"))
  room.main_loop
}
