# -*- coding: utf-8 -*-
# マルコフおかりん
require_relative 'helper'
# Albatro.logger = ActiveSupport::BufferedLogger.new(STDOUT)
Chat::VipRoom.single_open(:bot => @bots[:okarin], :max => 5)
