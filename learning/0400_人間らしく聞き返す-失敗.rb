# -*- coding: utf-8 -*-
# 人間らしく聞き返す-失敗
require_relative 'helper'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

messages = [
  "儚い花が散る",
  "大切な人はもういない",
  # "最近、大規模なデータを処理する技術が注目を集めています。",
  ".",
]

human = Albatro::ActorResponder.new(:messages => messages)
# human = Albatro::HumanResponder.new # 自分で入力するときはここを有効にする

Chat::VipRoom.open{|room|
  room.join(SBot.new(:responder => human, :name => "おかりん"))
  room.join(SBot.new(:responder => Albatro::WhatResponder.new, :name => "まゆしぃ"))
  room.main_loop
}
