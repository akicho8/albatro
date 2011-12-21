# -*- coding: utf-8 -*-
# 特定の言葉に反応してネットを駆使する
require File.expand_path(File.join(File.dirname(__FILE__), "helper"))
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

messages = [
  "明日の天気大丈夫かなあ",
  "今日の天気はどうかな",
  ".",
]

human = Albatro::ActorResponder.new(:messages => messages) 
# human = Albatro::HumanResponder.new # 自分で入力するときはここを有効にする

net_responder_run(Chat::VipRoom, human)
