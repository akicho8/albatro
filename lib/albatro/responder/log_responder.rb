# -*- coding: utf-8 -*-
require_relative "base"
require_relative "../morpheme"

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
    class LogResponder < Base
      attr_accessor :dictionary
      attr_reader :last_sorted_hash, :last_hash, :last_log # デバッグ用

      def initialize(*)
        super
        @dictionary = []
      end

      def dialogue(input, options = {})
        options = {
          :sort_type => @options[:sort_type],
        }.merge(options)

        keywords = Morpheme.instance.pickup_keywords(input, :keyword_connect => false, :reject => ["形容動詞語幹", "代名詞", "非自立"])
        @last_hash = {}
        @last_log = []
        @dictionary[0..-2].each_with_index{|parts, index| # 返事がないので最後の1つは取るための -2
          # 相手の発言の中に a b c があるとしたら {:index => 1, :count => 0〜3} みたいなハッシュを作る
          # count は何個ヒットしたかどうか
          count = keywords.find_all{|keyword|parts.any?{|part|part[:word] == keyword}}.size # 分解しているので、ここでの精度があがるわけだけど。
          @last_log << "#{index}:「#{input}」の単語(#{keywords.join('|')})は「#{parts.collect{|e|e[:word]}.join}」に#{count}個含まれる"
          if count >= 1
            @last_hash[index] = count
          end
        }
        @last_sorted_hash = @last_hash.sort_by{|index, count|
          if options[:sort_type] == :rand
            [-count, rand]
          else
            [-count, index] # 個数が同じなら古い物順
          end
        }
        index, count = @last_sorted_hash.first
        if index
          if parts = @dictionary[index.next]
            response = parts.collect{|e|e[:word]}.join
          end
          # response を置換するのもあり
        end
        # puts @last_log
        response
      end

      def study_from_string(str)
        if str.present?
          @dictionary << Morpheme.instance.analyze(str) # TODO: ここ分解する必要あるのか検討
          # p @dictionary.last
        end
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

  responder = Albatro::Responder::LogResponder.new
  responder.study_from_string("x")
  responder.study_from_string("返答0")
  responder.study_from_string("a")
  responder.study_from_string("返答1")
  responder.study_from_string("aとb")
  responder.study_from_string("返答2")
  responder.study_from_string("aとbとc")
  responder.study_from_string("返答3")
  p responder.dialogue("aとb")
  p responder.last_hash
  p responder.last_sorted_hash

  # Albatro::Responder::LogResponder.new.interactive(:messages => ["a", "b", "a"])
end
