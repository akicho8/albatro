# -*- coding: utf-8 -*-

# 基本ライブラリ
require_relative "albatro/logger"
require_relative "albatro/morpheme"
require_relative "albatro/markov_node"
require_relative "albatro/responder/base"
require_relative "albatro/version"

# 応答クラス
require_relative "albatro/responder/debug_responder"
require_relative "albatro/responder/actor_responder"
require_relative "albatro/responder/ask_responder"
require_relative "albatro/responder/human_responder"
require_relative "albatro/responder/laugh_responder"
require_relative "albatro/responder/learn_responder"
require_relative "albatro/responder/log_responder"
require_relative "albatro/responder/memory_responder"
require_relative "albatro/responder/markov_responder"
require_relative "albatro/responder/net_responder"
require_relative "albatro/responder/random_responder"
require_relative "albatro/responder/recommend_responder"
require_relative "albatro/responder/sweets_responder"
require_relative "albatro/responder/time_responder"
require_relative "albatro/responder/twitter_responder"
require_relative "albatro/responder/what_responder"
