# -*- coding: utf-8 -*-
# マルコフ任天堂
require_relative 'helper'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)
Chat::VipRoom.single_open(:bot => @bots[:famicom], :max => 4)
