# -*- coding: utf-8 -*-
# 形態素解析(MeCabをブラックボックス化)
#
# require "MeCab"
# sentence = "私は元気です。"
# puts "MeCab::VERSION #{MeCab::VERSION}"
# c = MeCab::Tagger.new("-d /opt/local/lib/mecab/dic/ipadic-utf8")
# c.parse(sentence)
# n = c.parseToNode(sentence)
# while n do
#   puts [n.surface, n.feature, n.cost].join("/")
#   n = n.next
# end

require "MeCab"
require "pp"
require "kconv"
require "singleton"
require "strscan"

require File.expand_path(File.join(File.dirname(__FILE__), "logger"))

module Albatro
  class Morpheme
    include Singleton

    #
    # コマンドラインインターフェイス
    #
    def self.execute(args = ARGV)
      require "optparse"
      opt = {}
      oparser = OptionParser.new{|oparser|
        oparser.on("-k", "--keyword", "キーワード抽出", TrueClass){|v|opt[:keyword] = v}
        oparser.on("-c", "--connect", "名詞連結", TrueClass){|v|opt[:connect] = v}
      }
      oparser.parse!(args)
      case
      when opt[:keyword]
        pp instance.pickup_keywords(args)
      when opt[:connect]
        instance.analyze_display(args, :connect => true)
      else
        instance.analyze_display(args)
      end
    end

    #
    # MecCabのオプション
    #
    attr_accessor :mecab_options

    #
    # MeCabのインスタンスを自力で設定したい場合用
    #
    #   Morpheme.instance.mecab = MeCab::Tagger.new("-d /opt/local/lib/mecab/dic/ipadic-utf8 -Ochasen")
    #
    attr_writer :mecab

    def initialize
      # FIXME: このハードコーディングをやめたい。export MECAB_DEFAULT_RC=/usr/local/Cellar/mecab/0.994/lib/mecab/dic/ipadic としても効かないし。
      @mecab_options = "-d /usr/local/Cellar/mecab/0.994/lib/mecab/dic/ipadic -Ochasen"
    end

    #
    # テキスト解析
    #
    #   p analyze("アヒルと鴨") #=>
    #
    #     [
    #       {:word => "アヒル", :senses => ["名詞", "一般"]},
    #       {:word => "と",     :senses => ["助詞", "並立助詞"]},
    #       {:word => "鴨",     :senses => ["名詞", "固有名詞", "人名", "姓"]},
    #     ]
    #
    def analyze(text)
      result = mecab.parse(text.to_s)
      parts = result.lines.collect{|line|
        line = line.strip
        next if line == "EOS"
        fields = line.split(/\s+/)
        {:word => fields[0], :senses => fields[3].split("-")} # FIXME: マジックナンバーを消したい
      }.compact
      Albatro.logger.debug(__parsed_result_as_table(parts)) if Albatro.logger
      parts
    end

    #
    # MeCabオブジェクト
    #
    # FIXME: これは private にするべきか？
    #
    def mecab
      @mecab ||= MeCab::Tagger.new([@mecab_options].flatten.join(" "))
    end

    module Utils
      #
      # 単語は固有名詞か？
      #
      #   p keyword?({:word => "アヒル", :senses => ["名詞", "一般"]}) #=> true
      #   これはテストでしか使われてない
      #
      def __keyword?(part)
        if false
          part[:senses].include?("名詞")
        else
          # 恋するプログラム参考
          if part[:senses].first == "名詞"
            part[:senses].drop(1).any?{|s|["一般", "固有名詞", "サ変接続", "形容動詞語幹"].include?(s)}
          end
        end
      end

      #
      # テキストからキーワードを抽出する
      #
      #  p pickup_keywords("夏花火と冬花火") #=> ["夏花火", "冬花火"]
      #
      #  連続する名詞は結合する
      #
      #  pickup_keywords("夏花火", :pickup => ["名詞"])                        # 名詞が含まれたもの
      #  pickup_keywords("夏花火", :pickup => ["名詞"], :reject => ["形容詞"]) # 形容詞が含まれてたらだめ
      #
      def pickup_keywords(text, options = {})
        options = {
          :pickup => ["名詞"],
          :keyword_connect => true,
        }.merge(options)
        parts = analyze(text)
        if options[:keyword_connect]
          parts = keyword_connect(parts)
        end
        parts = parts.find_all{|part|
          flag = false
          if options[:pickup]
            if options[:pickup].any?{|x|part[:senses].include?(x)}
              flag = true # 名詞のどれかが含まれている？
            end
          end
          if flag
            if options[:reject]
              if options[:reject].any?{|x|part[:senses].include?(x)}
                flag = false # 形容詞が含まれていたらダメ
              end
            end
          end
          flag
        }
        parts.collect{|part|part[:word]}
      end

      #
      # 連続する名詞を結合する
      #
      #   {:senses=>["名詞", "固有名詞", "人名", "姓"], :word=>"夏"},
      #   {:senses=>["名詞", "一般"],                   :word=>"花火"},
      #   {:senses=>["助詞", "並立助詞"],               :word=>"と"},
      #   {:senses=>["名詞", "一般"],                   :word=>"冬"},
      #   {:senses=>["名詞", "一般"],                   :word=>"花火"},
      #     ↓
      #   {:senses => ["名詞", "固有名詞", "人名", "姓", "一般"], :word => "夏花火"},
      #   {:senses => ["助詞", "並立助詞"],                       :word => "と"},
      #   {:senses => ["名詞", "一般"],                           :word => "冬花火"},
      #
      def keyword_connect(parts)
        match_parts_array = []
        match_parts = []
        keyword = nil
        senses = []
        store_ary = []
        (parts + [nil]).each{|part|
          if part && ["名詞"].any?{|x|part[:senses].include?(x)} && ["代名詞"].none?{|x|part[:senses].include?(x)}
            keyword ||= ""
            keyword << part[:word]
            senses += part[:senses]
          else
            if keyword
              store_ary << {:word => keyword, :senses => senses.uniq}
              keyword = nil
              senses = []
            end
            if part
              store_ary << part
            end
          end
        }
        store_ary
      end

      #
      # 引数に与えられた文字列の解析結果をそのまま表示(デバッグ用のインターフェイス)
      #
      #   analyze_display("アヒルと鴨") #=>
      #
      #     +--------+-----------------------+
      #     | 語彙   | 意味                  |
      #     +--------+-----------------------+
      #     | アヒル | 名詞 一般             |
      #     | と     | 助詞 並立助詞         |
      #     | 鴨     | 名詞 固有名詞 人名 姓 |
      #     +--------+-----------------------+
      #
      def analyze_display(text, options = {})
        options = {
          :connect => false, # 名詞を連結する？
        }.merge(options)
        items = analyze(text)
        if options[:connect]
          items = keyword_connect(items)
        end
        __parsed_result_as_table(items, options).display
      end

      def __parsed_result_as_table(items, options = {})
        require "rubygems"
        begin
          require "simple_table"
        rescue LoadError
        end
        out = ""
        if Object.const_defined?("SimpleTable")
          rows = items.collect{|item|
            {:word => item[:word], :senses => item[:senses].join(" ")}
          }
          select_columns = [
            {:key => :word,   :label => "語彙", :size => nil},
            {:key => :senses, :label => "意味", :size => nil},
          ]
          out = SimpleTable.generate(rows, :select_columns => select_columns, :in_code => Kconv::UTF8)
        else
          width = items.collect{|item|item[:word].kconv(Kconv::EUC, Kconv::UTF8).size}.max
          items.each{|item|
            left = item[:word].kconv(Kconv::EUC, Kconv::UTF8).rjust(width).kconv(Kconv::UTF8, Kconv::EUC)
            out << [left, " → ", item[:senses].join(" ")].join + "\n"
          }
        end
        out
      end

      #
      # テキストの揺れを軽減
      #
      #   p text_normalize("あ\tい") #=> "あ い"
      #
      def text_normalize(text)
        zenkaku_space = [0x3000].pack("U")
        text = text.to_s.gsub(/[#{zenkaku_space} ]+/, " ") # 全角スペース→半角スペース
        text.strip
      end

      #
      # テキストを文章単位に分割
      #
      #   p text_to_sentences("です\nそれと")             #=> ["です", "それと"]
      #   p text_to_sentences("あ！？これ！です。おわり") #=> ["あ！？", "これ！", "です。", "おわり"]
      #
      def text_to_sentences(text, options = {})
        options = {
          :suffix => %r/(！？|！|？|。|\r?\n)/,
        }.merge(options)
        ary = []
        text = text_normalize(text)
        scanner = StringScanner.new(text.to_s)
        loop do
          if length = scanner.exist?(options[:suffix])
            ary << scanner.peek(length)
            scanner.pos += length
          else
            ary << scanner.rest
            break
          end
        end
        ary.collect{|e|e.strip}.reject{|e|e.empty?}
      end

      # 読点の削除
      #
      #   削除する
      #     +------+------------------+
      #     | 昨日 | 名詞 副詞可能    |
      #     | で   | 助詞 格助詞 一般 |
      #     | 、   | 記号 読点        |
      #     +------+------------------+
      #     | それ | 名詞 代名詞 一般 |
      #     | が   | 助詞 格助詞 一般 |
      #     | 、   | 記号 読点        |
      #     +------+------------------+
      #     +------+---------------+
      #     | 昨日 | 名詞 副詞可能 |
      #     | は   | 助詞 係助詞   |
      #     | 、   | 記号 読点     |
      #     +------+---------------+
      #
      #   削除しない
      #     +------+-----------+
      #     | で   | 接続詞    |
      #     | 、   | 記号 読点 |
      #     +------+-----------+
      #
      #   文字列だけを見て正規表現で書くと
      #     gsub(/(.+(?:で|が|は))、/, '\1')
      #   になるけど削除しないケースの判別ができない
      #
      def touten_reject(parts)
        reject_one(parts, ["助詞"], ["記号", "読点"])
      end

      # 句点の削除
      #
      #   削除するケース
      #     +------+-----------+
      #     | 語彙 | 意味      |
      #     +------+-----------+
      #     | です | 助動詞    |
      #     | 。   | 記号 句点 |
      #     +------+-----------+
      #     +------+-------------+
      #     | 語彙 | 意味        |
      #     +------+-------------+
      #     | です | 助動詞      |
      #     | ね   | 助詞 終助詞 |
      #     | 。   | 記号 句点   |
      #     +------+-------------+
      #     +------+-----------+
      #     | 語彙 | 意味      |
      #     +------+-----------+
      #     | し   | 動詞 自立 |
      #     | まし | 助動詞    |
      #     | た   | 助動詞    |
      #     | 。   | 記号 句点 |
      #     +------+-----------+
      #     +------+-----------+
      #     | 語彙 | 意味      |
      #     +------+-----------+
      #     | し   | 動詞 自立 |
      #     | ます | 助動詞    |
      #     | 。   | 記号 句点 |
      #     +------+-----------+
      #     +------+---------------+
      #     | 語彙 | 意味          |
      #     +------+---------------+
      #     | し   | 動詞 自立     |
      #     | て   | 助詞 接続助詞 |
      #     | いる | 動詞 非自立   |
      #     | 。   | 記号 句点     |
      #     +------+---------------+
      #     +--------+------------------+
      #     | 語彙   | 意味             |
      #     +--------+------------------+
      #     | 皆さん | 名詞 一般        |
      #     | が     | 助詞 格助詞 一般 |
      #     | いる   | 動詞 自立        |
      #     | 。     | 記号 句点        |
      #     +--------+------------------+
      #
      #   削除しないケース
      #     +------+------------------+
      #     | 語彙 | 意味             |
      #     +------+------------------+
      #     | 私   | 名詞 代名詞 一般 |
      #     | 。   | 記号 句点        |
      #     +------+------------------+
      #
      def kuten_reject(parts)
        parts = reject_one(parts, ["助動詞"],         ["記号", "句点"]) # です。(し)ます。(しまし)た。
        parts = reject_one(parts, ["助詞", "終助詞"], ["記号", "句点"]) # (です)ね。
        parts = reject_one(parts, ["動詞", "非自立"], ["記号", "句点"]) # (〜て)いる。
        parts = reject_one(parts, ["動詞", "自立"],   ["記号", "句点"]) # (皆さんが)いる。
      end

      # 特定の並びを削除する
      #
      #  reject_one(parts, ["A"], ["B"]) の場合 ["B"] の位置のものを削除
      #
      def reject_one(parts, prev_senses, current_senses)
        parts = parts.dup
        loop do
          if index = parts.find_index{|part|current_senses.all?{|e|part[:senses].include?(e)}}
            before_index = index - 1
            if before_index >= 0
              before_part = parts[before_index]
              if prev_senses.all?{|e|before_part[:senses].include?(e)}
                parts.delete_at(index)
                next
              end
            end
          end
          break
        end
        parts
      end
    end

    include Utils
  end
end

if $0 == __FILE__
  p Albatro::Morpheme.instance.touten_reject(Albatro::Morpheme.instance.analyze("昨日は、"))
  p Albatro::Morpheme.instance.touten_reject(Albatro::Morpheme.instance.analyze("で、"))
  p Albatro::Morpheme.instance.touten_reject(Albatro::Morpheme.instance.analyze("僕が、"))
  p Albatro::Morpheme.instance.touten_reject(Albatro::Morpheme.instance.analyze("僕は、"))

  p Albatro::Morpheme.instance.text_to_sentences("あ！？い！う。え(笑)あれれ this \nあいうえお")
  Albatro::Morpheme.instance.analyze_display("あ！？い！　う。え(笑)")
  Albatro::Morpheme.instance.analyze_display("アヒルと鴨(笑)")
  Albatro::Morpheme.instance.analyze_display("アヒルと鴨(笑)")
  Albatro::Morpheme.instance.analyze_display("")
  Albatro::Morpheme.execute(["初音ミクと鏡音リン"])
  Albatro::Morpheme.execute(["-k", "初音ミクと鏡音リン(笑)"])
  Albatro::Morpheme.execute(["-c", "初音ミクと鏡音リン"])

end
