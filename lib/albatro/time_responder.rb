# -*- coding: utf-8 -*-

require File.expand_path(File.join(File.dirname(__FILE__), "responder"))

module Albatro
  class TimeResponder < Responder
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
        "いま#{Time.current.hour}時ぐらい"
      end
    end
  end
end

if $0 == __FILE__
  Albatro::TimeResponder.new.interactive(:messages => ["今何時だろ？"])
end
