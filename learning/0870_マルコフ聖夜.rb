# -*- coding: utf-8 -*-
# マルコフ聖夜
require_relative 'helper'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)
Chat::VipRoom.single_open(:bot => @bots[:mennaku], :max => 5)
