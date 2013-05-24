# -*- coding: utf-8 -*-
# 0300_ネットを駆使する_ぐぐる.rb
require_relative 'helper'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

messages = [
  "人工無能とは何ですか",
  ".",
]

human = Albatro::ActorResponder.new(:messages => messages)
# human = Albatro::HumanResponder.new # 自分で入力するときはここを有効にする

net_responder_run(Chat::VipRoom, human)
