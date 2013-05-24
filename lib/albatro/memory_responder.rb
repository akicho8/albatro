# -*- coding: utf-8 -*-
require_relative "responder"
require_relative "refer_methods"

module Albatro
  #
  # 指定したメッセージを順に発言する
  #
  #  responder = Albatro::MemoryResponder.new(:messages => ["1", "2"])
  #  p responder.dialogue("") #=> "1"
  #  p responder.dialogue("") #=> "2"
  #  p responder.dialogue("") #=> "1"
  #
  class MemoryResponder < Responder
    include ReferMethods

    attr_accessor :dictionary

    def initialize(*)
      super
      @dictionary = {}
      @unknown_keyword = nil
      @mode = "watch"
    end

    def keyword_get(input)
      keyword_str = nil
      sense_order_match_senses.each{|senses|
        if keyword_str = sense_order_match(input, senses)
          break
        end
      }
      keyword_str
    end

    def dialogue(input, options = {})
      response = nil
      case @mode
      when "watch"
        if str = keyword_get(input)
          if r = @dictionary[str]
            response = r
          else
            # 1. 見つからないので聞く
            @unknown_keyword = str
            response = str + "って？"
            @mode = "memory"
          end
        end
      when "memory"
        # 2. 記憶する
        if input.present?
          @dictionary[@unknown_keyword] = input
          @unknown_keyword = nil
          @mode = "watch"
          response = "なるほど"
        end
      end
      response
    end
  end
end

if $0 == __FILE__
  # Albatro::MemoryResponder.new.interactive(:messages => ["夢の中で会ったような…", "輪廻のこと", "夢の中とは？"])
  Albatro::MemoryResponder.new.interactive(:messages => ["世界卓球はじまるな", "輪廻のこと", "夢の中とは？"])
end
