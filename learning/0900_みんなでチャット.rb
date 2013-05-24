# -*- coding: utf-8 -*-
# みんなでチャット
require_relative 'helper'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)
Albatro.logger = nil

# class RandomChat < Chat::SilentRoom
class RandomChat < Chat::VipRoom
  alias_method :next_turn, :_switch_other_member
end
RandomChat.open(:name => "みんなのチャンネル"){|room|
  @bots.each{|key, bot|room.join(bot)}
  room.main_loop(:max => 1000)
}
