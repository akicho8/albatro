# -*- coding: utf-8 -*-
# 聞いて覚える
require_relative 'helper'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

messages = [
  "世界卓球今日から始まるらしいな",
  "知らん",
  "ところで世界卓球とは？",
  ".",
]
human = Albatro::ActorResponder.new(:messages => messages)
# human = Albatro::HumanResponder.new # 自分で入力するときはここを有効にする

Chat::VipRoom.open{|room|
  room.join(SBot.new(:responder => human, :name => "おかりん"))
  room.join(SBot.new(:responder => Albatro::MemoryResponder.new, :name => "まゆしぃ"))
  room.main_loop{
    room.everyone_talk
  }
}
