# -*- coding: utf-8 -*-
# ログの中から探す
require File.expand_path(File.join(File.dirname(__FILE__), "helper"))
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

Chat::VipRoom.open{|room|
  room.join(SBot.new(:responder => Albatro::ActorResponder.new(:messages => ["卓球でもやるか", "."]), :name => "橋田至"))
  room.join(SBot.new(:responder => Albatro::ActorResponder.new(:messages => ["やろうやろう"]), :name => "阿万音鈴羽"))
  room.join(SBot.new(:responder => Albatro::ActorResponder.new(:messages => ["テレ東の世界卓球への力の入れ具合いは異常", "."]), :name => "橋田至"))
  room.join(SBot.new(:responder => Albatro::ActorResponder.new(:messages => ["興味ないわ"]), :name => "阿万音鈴羽"))
  room.join(SBot.new(:responder => Albatro::ActorResponder.new(:messages => ["なんかテレ東で卓球やってる"]), :name => "おかりん"))
  room.join(SBot.new(:responder => Albatro::LogResponder.new, :may_study => true, :name => "まゆしぃ"))
  room.main_loop
}
