# -*- coding: utf-8 -*-
# マルコフおかりん
require File.expand_path(File.join(File.dirname(__FILE__), "helper"))
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)
Chat::VipRoom.single_open(:bot => @bots[:okarin], :max => 5)
