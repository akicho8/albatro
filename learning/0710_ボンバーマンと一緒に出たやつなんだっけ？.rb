# -*- coding: utf-8 -*-
require_relative 'helper'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

responder = Albatro::Recommend2Responder.new

messages = [
  "ボンバーマンとバイナリーランドは発売日が同じでした。",
  "ハドソンのボンバーマンとバイナリーランドを一緒に買いました。",
]

messages.each{|str|
  # Albatro::Morpheme.instance.analyze_display(str)
  responder.study_from(str)
}

# Albatro::Morpheme.instance.analyze_display("カラテカは名作")
# pp responder.dictionary

human_messages = [
  "ボンバーマンと一緒に出たやつなんだっけ？",
  "そう、それ！",
  ".",
]

human = Albatro::ActorResponder.new(:messages => human_messages)
# human = Albatro::HumanResponder.new # 自分で入力するときはここを有効にする

Chat::VipRoom.open{|room|
  room.join(SBot.new(:responder => human, :name => "おかりん"))
  room.join(SBot.new(:responder => responder, :name => "まゆしぃ"))
  room.main_loop
}
