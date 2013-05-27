# -*- coding: utf-8 -*-
require_relative "base"

module Albatro
  module Responder
    #
    # 指定したメッセージを順に発言する
    #
    #  responder = Albatro::Responder::LearnResponder.new(:messages => ["1", "2"])
    #  p responder.dialogue("") #=> "1"
    #  p responder.dialogue("") #=> "2"
    #  p responder.dialogue("") #=> "1"
    #
    class LearnResponder < Base
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
end

if $0 == __FILE__
  # ・昔の会話を覚ておく
  #   人間1: あれ買った？ (Responder::ActorResponderを使う)
  #   人間2: ドラクエなら買ったよ
  #   人間3: あれ買った？
  #    CPU: ドラクエなら買ったよ
  responder = Albatro::Responder::LearnResponder.new
  responder.study_from_string("a")
  responder.study_from_string("b")
  p responder.dialogue("a")
  Albatro::Responder::LearnResponder.new.interactive(:messages => ["a", "b", "a"])
end
