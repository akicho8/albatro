# -*- coding: utf-8 -*-
require_relative "base"
require_relative "../refer_methods"

module Albatro
  module Responder
    module Taisetunahitotte2Dialogue
      #
      # 名詞 + 助動詞 + 一般名詞 について言及する
      #
      #   p dialogue("大切な人はもういない") #=> "大切な人って？
      #
      def dialogue(input, options = {})
        return response if response = super
        sense_order_match_senses.each{|senses|
          if response = sense_order_match(input, senses)
            response += "って？"
            break
          end
        }
        response
      end
    end

    class AskResponder < Base
      include ReferMethods
      include Taisetunahitotte2Dialogue
    end
  end
end

if $0 == __FILE__
  Albatro::Responder::AskResponder.new.interactive(:messages => ["夢の中で会った"])
end
