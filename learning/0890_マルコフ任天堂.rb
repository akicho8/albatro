# -*- coding: utf-8 -*-
# マルコフ任天堂
require File.expand_path(File.join(File.dirname(__FILE__), "helper"))
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)
Chat::VipRoom.single_open(:bot => @bots[:famicom], :max => 4)
