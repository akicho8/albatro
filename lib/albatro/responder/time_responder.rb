# -*- coding: utf-8 -*-

require_relative "base"

module Albatro
  module Responder
    class TimeResponder < Base
      #
      # 時間に対してはほとんど進んで言及できる
      #
      def refer?(input, options = {})
        input.match(/何時/) && rand(2).zero?
      end

      #
      # 時間を聞かれたら応答
      #
      def dialogue(input, options = {})
        if input.match(/何時/)
          "いま#{Time.now.hour}時ぐらい"
        end
      end
    end
  end
end

if $0 == __FILE__
  Albatro::Responder::TimeResponder.new.interactive(:messages => ["今何時だろ？"])
end
