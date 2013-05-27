# -*- coding: utf-8 -*-
# 特定の言葉に反応する
require_relative 'helper'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

class WatchResponder < Albatro::Responder::Base
  def dialogue(input, options = {})
    case input
    when /ドビュッシー/
      "いま#{$&}っていった？"
    end
  end
end

messages = [
  "昨日、近所で高橋名人見たんです",
  "昨日、近所でドビュッシー見たんです",
]

human = Albatro::Responder::ActorResponder.new(:messages => messages)
# human = Albatro::Responder::HumanResponder.new # 自分で入力するときはここを有効にする

Chat::VipRoom.open{|room|
  room.join(SBot.new(:responder => human, :name => "おかりん"))
  room.join(SBot.new(:responder => Responder::WatchResponder.new, :name => "まゆしぃ"))
  room.main_loop
}
