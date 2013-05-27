# -*- coding: utf-8 -*-
# 特定の言葉に反応してネットを駆使する
require_relative 'helper'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

messages = [
  "明日の天気大丈夫かなあ",
  "今日の天気はどうかな",
  ".",
]

human = Albatro::Responder::ActorResponder.new(:messages => messages) 
# human = Albatro::Responder::HumanResponder.new # 自分で入力するときはここを有効にする

net_responder_run(Chat::VipRoom, human)
