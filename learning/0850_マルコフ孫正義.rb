# -*- coding: utf-8 -*-
# マルコフ孫正義
require_relative 'helper'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)
Chat::VipRoom.single_open(:bot => @bots[:masason], :max => 5)
