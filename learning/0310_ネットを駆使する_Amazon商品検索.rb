# -*- coding: utf-8 -*-
# 0310_ネットを駆使する_本.rb
require_relative 'helper'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

messages = [
  "伊坂幸太郎の本が欲しい",
  ".",
]

human = Albatro::ActorResponder.new(:messages => messages)
# human = Albatro::HumanResponder.new # 自分で入力するときはここを有効にする

net_responder_run(Chat::VipRoom, human)

