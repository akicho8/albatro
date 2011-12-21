# -*- coding: utf-8 -*-
$KCODE = "u"

# 基本ライブラリ
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/logger"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/morpheme"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/markov_node"))

# 応答クラス
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/debug_responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/actor_responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/ask_responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/human_responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/laugh_responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/learn_responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/log_responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/memory_responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/markov_responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/net_responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/random_responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/recommend_responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/sweets_responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/time_responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/twitter_responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "albatro/what_responder"))

module Albatro
  VERSION = "1.0.0"
end
