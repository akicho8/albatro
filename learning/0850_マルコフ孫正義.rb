# -*- coding: utf-8 -*-
# マルコフ孫正義
require File.expand_path(File.join(File.dirname(__FILE__), "helper"))
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)
Chat::VipRoom.single_open(:bot => @bots[:masason], :max => 5)
