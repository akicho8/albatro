# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "responder"))

module Albatro
  #
  # 指定したメッセージを順に発言する
  #
  #  responder = Albatro::LearnResponder.new(:messages => ["1", "2"])
  #  p responder.dialogue("") #=> "1"
  #  p responder.dialogue("") #=> "2"
  #  p responder.dialogue("") #=> "1"
  #
  class LearnResponder < Responder
    attr_accessor :dictionary

    def initialize(*)
      super
      @dictionary = []
    end

    def dialogue(input, options = {})
      if index = @dictionary.find_index(input)
        @dictionary[index.next]
      end
    end

    def study_from_string(*args)
      @dictionary += args
    end
  end
end

if $0 == __FILE__
  # ・昔の会話を覚ておく
  #   人間1: あれ買った？ (ActorResponderを使う)
  #   人間2: ドラクエなら買ったよ
  #   人間3: あれ買った？
  #    CPU: ドラクエなら買ったよ
  responder = Albatro::LearnResponder.new
  responder.study_from_string("a")
  responder.study_from_string("b")
  p responder.dialogue("a")
  Albatro::LearnResponder.new.interactive(:messages => ["a", "b", "a"])
end
