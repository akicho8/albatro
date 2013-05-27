# -*- coding: utf-8 -*-
# ログの中から探す
require_relative 'helper'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

Chat::VipRoom.open{|room|
  room.join(SBot.new(:responder => Albatro::Responder::ActorResponder.new(:messages => ["卓球でもやるか", "."]), :name => "橋田至"))
  room.join(SBot.new(:responder => Albatro::Responder::ActorResponder.new(:messages => ["やろうやろう"]), :name => "阿万音鈴羽"))
  room.join(SBot.new(:responder => Albatro::Responder::ActorResponder.new(:messages => ["テレ東の世界卓球への力の入れ具合いは異常", "."]), :name => "橋田至"))
  room.join(SBot.new(:responder => Albatro::Responder::ActorResponder.new(:messages => ["興味ないわ"]), :name => "阿万音鈴羽"))
  room.join(SBot.new(:responder => Albatro::Responder::ActorResponder.new(:messages => ["なんかテレ東で卓球やってる"]), :name => "おかりん"))
  room.join(SBot.new(:responder => Albatro::Responder::LogResponder.new, :may_study => true, :name => "まゆしぃ"))
  room.main_loop
}
