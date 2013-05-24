# -*- coding: utf-8 -*-
# マルコフエア本
require_relative 'helper'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)
Chat::VipRoom.single_open(:bot => @bots[:eamoto], :max => 4)
