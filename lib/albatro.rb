# -*- coding: utf-8 -*-

# 基本ライブラリ
require_relative "albatro/logger"
require_relative "albatro/responder"
require_relative "albatro/morpheme"
require_relative "albatro/markov_node"

# 応答クラス
require_relative "albatro/debug_responder"
require_relative "albatro/actor_responder"
require_relative "albatro/ask_responder"
require_relative "albatro/human_responder"
require_relative "albatro/laugh_responder"
require_relative "albatro/learn_responder"
require_relative "albatro/log_responder"
require_relative "albatro/memory_responder"
require_relative "albatro/markov_responder"
require_relative "albatro/net_responder"
require_relative "albatro/random_responder"
require_relative "albatro/recommend_responder"
require_relative "albatro/sweets_responder"
require_relative "albatro/time_responder"
require_relative "albatro/twitter_responder"
require_relative "albatro/what_responder"

module Albatro
  VERSION = "1.1.0"
end
