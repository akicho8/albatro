# -*- coding: utf-8 -*-
require_relative "responder"

module Albatro
  #
  # 指定したメッセージを順に発言する
  #
  #  responder = Albatro::ActorResponder.new(:messages => ["1", "2"])
  #  p responder.dialogue("") #=> "1"
  #  p responder.dialogue("") #=> "2"
  #  p responder.dialogue("") #=> "1"
  #
  class ActorResponder < Responder
    def dialogue(input, options = {})
      @message_counter ||= 0
      raise ArgumentError, "@options[:messages] を指定してください" if @options[:messages].blank?
      if @message_counter < @options[:messages].size
        @options[:messages][@message_counter.modulo(@options[:messages].size)].tap{@message_counter += 1}
      end
    end
  end
end

if $0 == __FILE__
  Albatro::ActorResponder.new(:messages => ["1", "2"]).interactive(:messages => ["a", "b"])
end
