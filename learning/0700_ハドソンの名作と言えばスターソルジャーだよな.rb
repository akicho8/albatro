# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "helper"))
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

responder = Albatro::Recommend2Responder.new

messages = [
  "迷宮組曲とスターソルジャーはハドソンが開発しました",
]
messages.each{|str|
  # Albatro::Morpheme.instance.analyze_display(str)
  responder.study_from(str)
}

# Albatro::Morpheme.instance.analyze_display("カラテカは名作")

# pp responder.dictionary

human_messages = [
  "ハドソンの名作と言えばスターソルジャーだよな",
  ".",
]

human = Albatro::ActorResponder.new(:messages => human_messages)
# human = Albatro::HumanResponder.new # 自分で入力するときはここを有効にする

Chat::VipRoom.open{|room|
  room.join(SBot.new(:responder => human, :name => "おかりん"))
  room.join(SBot.new(:responder => responder, :name => "まゆしぃ"))
  room.main_loop
}
