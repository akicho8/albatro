# -*- coding: utf-8 -*-
# 特定の言葉に反応してネットを駆使する
require_relative 'helper'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

messages = [
  "初音ミクの画像ください",
  ".",
]

human = Albatro::Responder::ActorResponder.new(:messages => messages) 
# human = Albatro::Responder::HumanResponder.new # 自分で入力するときはここを有効にする

net_responder_run(Chat::VipRoom, human)
