# -*- coding: utf-8 -*-

require_relative "base"

module Albatro
  module Responder
    #
    # ランダムに発言する
    #
    class RandomResponder < Base
      attr_accessor :dictionary

      def initialize(*)
        super
        @dictionary = []
        @count = 0
      end

      def dialogue(input, options = {})
        @dictionary[@count.modulo(@dictionary.size)].tap{@count += 1}
      end

      def study_from_string(str)
        if str.present?
          @dictionary += [str]
          @dictionary.uniq!
          @dictionary.shuffle!
        end
      end
    end
  end
end

if $0 == __FILE__
  responder = Albatro::Responder::RandomResponder.new
  responder.study_from_string("a")
  responder.study_from_string("b")
  responder.study_from_string("c")
  p responder.dialogue("")
  p responder.dialogue("")
  p responder.dialogue("")
end
