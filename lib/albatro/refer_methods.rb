# -*- coding: utf-8 -*-
require_relative "morpheme"
require_relative "refer_methods"

module Albatro
  module ReferMethods
    #
    # 名詞 + 助動詞 + 一般名詞のような並びにマッチしたら、その部分の文字列を取得する
    #
    #   p sense_order_match("大切な人", [["名詞"], ["助動詞"], ["名詞", "一般"]]) #=> "大切な人"
    #
    # 「大切な人」を取得したい場合、それを分解すると
    #   {:word => "大切", :senses => ["名詞", "形容動詞語幹"]},
    #   {:word => "な",   :senses => ["助動詞"]},
    #   {:word => "人",   :senses => ["名詞", "一般"]}
    # となるので、senses の中に、含まれるもの「どれか」を順に並べていったのを引数に渡すと「大切な人」の部分だけが抽出できる
    #
    # リファクタリング前のコード
    #
    #    parts = Morpheme.instance.analyze(input)
    #    if index = parts.find_index{|part|part[:senses].include?("名詞")}
    #      if part = parts[index + 1]
    #        if part[:senses].include?("助動詞")
    #          if part = parts[index + 2]
    #            if part[:senses].include?("名詞") && part[:senses].include?("一般")
    #              parts[index .. index+2].collect{|part|part[:word]}.join + "って？"
    #            end
    #          end
    #        end
    #      end
    #    end
    #
    def sense_order_match(input, infos)
      parts = Morpheme.instance.analyze(input)

      # 「こんな + の + 絶対」が全部まとまってしまうのでダメ
      # parts = Morpheme.instance.keyword_connect(parts)

      # [123] の単語のなかから [12] の並びを調べるなら 3 - 2 = 1 回シフトする。チェックの回数的には +1 して 2 になる
      # [12]
      #  [12]
      check_count = (parts.size - infos.size) + 1

      match_parts = nil
      check_count.times{|base_index|
        _parts = parts[base_index, infos.size] # 0回目は0から2件, 1回目は1から2件 取得
        Albatro.logger.debug("#{base_index}から#{infos.size}件は#{_parts.collect{|e|e[:senses]}.inspect}で#{infos.inspect}のすべての並びが含まれるか？") if Albatro.logger
        if infos.enum_for(:each_with_index).all?{|info, index|
            if part = _parts[index]
              # info をハッシュにし all か any の指定に合わせて
              # info.all? info.any? に変えるとより汎用的なものになる
              # 現状は指定したすべてが含まれる all? のみ
              info.all?{|sense|
                part[:senses].include?(sense) # ["形容詞", "自立"] の中に指定した "形容詞" が含まれるか？
              }
            end
          }
          match_parts = _parts
          break
        end
      }
      if match_parts
        match_parts.collect{|part|part[:word]}.join
      end
    end

    def sense_order_match_senses
      [
        [["接頭詞", "名詞接続"], ["名詞", "一般"], ["助動詞"], ["名詞", "一般"]], # 大規模なデータ
        [["副詞"], ["名詞"], ["助動詞"], ["名詞", "一般"]],                       # とっても大切な人
        [["名詞"], ["助動詞"], ["名詞", "一般"]],                                 # 大切な人
        [["名詞"], ["助詞"], ["名詞"]],                                           # 夢の中
        [["連体詞"], ["名詞", "非自立", "一般"]],                                 # こんなの
        [["形容詞"], ["名詞", "一般"]],                                           # 弱い私, 儚い夢
        [["形容詞"], ["名詞", "一般"]],                                           # 弱い私, 儚い夢
        [["名詞",  "一般"], ["名詞", "サ変接続"]],                                # 世界卓球
      ]
    end
  end
end

if $0 == __FILE__
  require_relative "base"

  class C < Albatro::Responder
    include Albatro::ReferMethods
    def dialogue(input, options = {})
      response = nil
      sense_order_match_senses.each{|senses|
        if response = sense_order_match(input, senses)
          response = "【#{response}】"
          break
        end
      }
      response
    end
  end

  messages = [
    "夢の中で会った、ような・・・・・",
    "それはとっても嬉しいなって",
    "もう何も恐くない",
    "奇跡も、魔法も、あるんだよ",
    "後悔なんて、あるわけない",
    "こんなの絶対おかしいよ",
    "本当の気持ちと向き合えますか？",
    "あたしって、ほんとバカ",
    "そんなの、あたしが許さない",
    "もう誰にも頼らない",

    "儚い夢が",
    "とっても大切な人",
    "大切な人はもういない",
    "大規模なデータ",
    "弱い私",
  ]

  messages.each{|message|
    Albatro::Morpheme.instance.analyze_display(message)
  }

  C.new(:trace => false).interactive(:messages => messages)
end
