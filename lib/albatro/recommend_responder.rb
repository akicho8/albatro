# -*- coding: utf-8 -*-
require_relative "responder"
require_relative "morpheme"

module Albatro
  #
  # この商品を買った人はこんな商品も買っています
  #
  #   obj = RecommendResponder.new
  #   obj.study_from_string("AAとCCとCC")
  #   p obj.dictionary     #=> {"CC"=>{"AA"=>1}, "AA"=>{"CC"=>1}}
  #   obj.study_from_string("BBとCC")
  #   obj.study_from_string("BBとDDとCC")
  #   p obj.dialogue("AA") #=> "AAを発言した人はCCも発言しています"
  #   p obj.dialogue("CC") #=> "CCを発言した人はBBやAAも発言しています"
  #   p obj.dialogue("EE") #=> nil
  #
  class RecommendResponder < Responder
    attr_accessor :dictionary

    def default_options
      super.merge(:sample_at => :first)
    end

    def initialize(*)
      super
      @dictionary = {}
    end

    #
    # この商品を買った人はこんな商品も買っています
    #
    #   p dialogue("AA") #=> "AAを発言した人はCCも発言しています"
    #
    def dialogue(input, options = {})
      options = {
        :count => 2,            # おすすめする単語の数
      }.merge(options)
      if input.present?
        words = Morpheme.instance.pickup_keywords(input)
        words = words.find_all{|word|@dictionary[word]} # 辞書を持っている単語を順に探す
        word = array_sample(words, :sample_at => @options[:sample_at])
        if word
          hash = @dictionary[word]
          recommend_words = hash.sort_by{|key, value|-value} # カウント数が多い順
          recommend_words = recommend_words.collect{|key, value|key} # key(文字)だけ取得

          # X: AやB
          # Y: Bもね
          # となるのを禁止するため相手の発言に元々含まれていたら除外する
          recommend_words = recommend_words.reject{|key|input.include?(key)}

          message_build(input, word, recommend_words.take(options[:count]))
        end
      end
    end

    #
    # 単語をキーにしてそれ以外の単語を特徴ベクトル化する
    #
    #   study_from_string("AAとCC")
    #   study_from_string("BBとCC")
    #   p dictionary #=> {"AA"=>{"CC"=>1}, "BB" => {"CC" => 1}, "CC"=>{"AA"=>1, "BB" => 1}}
    #
    #   特徴ベクトル = 単語の頻度のセット表現 = bag of words = BOW とも呼ぶらしい
    #
    #   ハッシュのキーの多さを見ると他のものとペアで頻出している度合がわかる。
    #   人気があるかどうかではないので注意すること。
    #   (CCを単独で使っている場合、人気はあるが、辞書は変化がないことから)
    #
    def study_from_string(*args)
      words = Morpheme.instance.pickup_keywords(args, :reject => ["形容動詞語幹", "代名詞", "非自立", "サ変接続"], :keyword_connect => true).uniq
      if words.size >= 2
        words.each{|word|
          @dictionary[word] ||= {}
          item = @dictionary[word]
          others = words - [word]
          others.each{|other|
            item[other] ||= 0
            item[other] += 1
          }
        }
      end
    end

    def message_build(input, word, recommend_words)
      "#{word}を発言した人は" + recommend_words.join("や") + "も発言しています"
    end
  end

  class Recommend2Responder < RecommendResponder
    def dialogue(input, options = {})
      super(input, options.merge(:count => 1))
    end

    def message_build(input, word, recommend_words)
      if input.match(/？/)
        "もしかして" + recommend_words.join("か") + "？"
      else
        recommend_words.join("や") + "だろ常考"
      end
    end
  end
end

if $0 == __FILE__
  # Albatro::Morpheme.instance.analyze_display("16連射できないでしょ")
  # Albatro::Morpheme.instance.analyze_display("高橋名人と毛利名人はどっちがすごいの？")

  messages = [
    # "高橋名人 - 1980年代後半にファミコンの名人として一世を風靡した。毎秒16回の速さでコントローラのボタンなどを押す16連射は代名詞である。「ゲームは1日1時間」の名言を残したことで有名。",
    # "「高橋名人の冒険島」シリーズの主人公だったことは有名だが、派生作品のTVアニメ「BUGってハニー」で主題歌を歌っていたことはあまり知られていない。",

    # "ロードランナーの裏技しってる？",
    # "ファミコンのロードランナーやったことある？",
    # "アイスクライマーやったことある？",
    "アイスクライマーとロードランナーとバンゲリングベイ持ってる",
    "アイスクライマーとバンゲリングベイどっちが好き？",
    "バンゲリングベイだけどスターフォースの方が得意",
  ]
  obj = Albatro::RecommendResponder.new
  messages.each{|message|
    # Albatro::Morpheme.instance.analyze_display(message)
    obj.study_from_string(message)
  }
  pp obj.dictionary
  # puts obj.foobar
  # exit
  obj.dictionary.keys.each{|key|
    puts obj.dialogue(key)
  }
  10.times {
    p obj.dialogue("ファミコン")
  }
  exit

  obj = Albatro::RecommendResponder.new
  obj.study_from_string("AAとCCとCC")
  p obj.dictionary
  obj.study_from_string("BBとCC")
  p obj.dictionary
  obj.study_from_string("BBとDDとCC")
  p obj.dictionary
  p obj.dialogue("AA")
  p obj.dialogue("CC")
  p obj.dialogue("EE")

  obj = Albatro::RecommendResponder.new
  obj.study_from_string("親譲りで無鉄砲青空")
  obj.study_from_string("親譲りで青空")
  p obj.dialogue("親譲りの無鉄砲")

  # RecommendResponder.new.interactive
end

# Local Variables: ***
# compile-command: "ruby -Ku -rubygems -I..:../..:../lib ../../test/test_recommend_responder.rb" ***
# End: ***
