# -*- coding: utf-8 -*-
# 一方的にしゃべる
require File.expand_path(File.join(File.dirname(__FILE__), "helper"))
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)

responder = Albatro::RandomResponder.new
responder.study_from(:file => File.join(File.dirname(__FILE__), "../resources/yoshinoya_2ch_short.txt"), :format => :lines)
# responder.study_from(:file => File.join(File.dirname(__FILE__), "../resources/eva_asuka_short.txt"), :format => :lines)
# responder.study_from(:file => File.join(File.dirname(__FILE__), "../resources/eva_short.txt"), :format => :lines)

Chat::VipRoom.open{|room|
  room.join(SBot.new(:responder => responder, :name => "まゆしぃ"))
  room.main_loop(:max => 3)
}
