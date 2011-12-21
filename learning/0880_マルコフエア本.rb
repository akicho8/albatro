# -*- coding: utf-8 -*-
# マルコフエア本
require File.expand_path(File.join(File.dirname(__FILE__), "helper"))
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)
Chat::VipRoom.single_open(:bot => @bots[:eamoto], :max => 4)
