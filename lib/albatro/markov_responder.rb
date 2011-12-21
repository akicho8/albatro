# -*- coding: utf-8 -*-
# -*- compile-command: "ruby markov_responder.rb" -*-
# -*- compile-command: "ruby test_markov_responder.rb" -*-
#
# マルコフ連鎖アルゴリズム
#
# ■1.以下の3つの文章を学習
#
# 私は速い虫だ
# 私が速い魚だ
# 私が速い虫よ
#
# ■2. 辞書の内容
#
#  "私"   => {"が" => {"速い" => nil}, "は" => {"速い" => nil}}
#  "は"   => {"速い" => {"虫" => nil}}
#  "が"   => {"速い" => {"魚" => nil, "虫" => nil}}
#  "速い" => {"魚" => {"だ" => nil}, "虫" => {"よ" => nil, "だ" => nil}}
#  "虫"   => {"よ" => nil, "だ" => nil}
#  "魚"   => {"だ" => nil}
#  "だ"   => nil
#  "よ"   => nil
#
# dictionary = {
#   "私"   => {"が"   => ["速い", "速い"], "は" => ["速い"]},
#   "は"   => {"速い" => ["虫"]},
#   "が"   => {"速い" => ["魚", "虫"]},
#   "速い" => {"魚"   => ["だ"], "虫" => ["だ", "よ"]},
#   "虫"   => {"よ"   => nil, "だ" => nil},
#   "魚"   => {"だ"   => nil},
# }
#
# ■3. ここから上の文章にはない「私が速い虫だ」が作られる手順
#
# p dictionary["私"]         #=> {"が"=>["速い", "速い"], "は"=>["速い"]}
# p dictionary["私"]["が"]   #=> ["速い", "速い"]
# p dictionary["が"]["速い"] #=> ["魚", "虫"]
# p dictionary["速い"]["虫"] #=> ["だ", "よ"]
# p dictionary["虫"]["だ"]   #=> nil

require File.expand_path(File.join(File.dirname(__FILE__), "responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "morpheme"))
require File.expand_path(File.join(File.dirname(__FILE__), "markov_node"))

require "enumerator"
require "pathname"
require "pp"

module Albatro
  class MarkovBaseResponder < Responder
    def initialize(*)
      super
      dictionary
    end

    def default_options
      super.merge({
          :uniquesuffix => true,  # サフィックスをユニークにするか？
          :prefix       => 2,     # プレフィクス個数(2が妥当, 3以上にすると正しい文章になりやすくなるが面白味がなくなる)
          :min_depth    => 2,     # 学習するときの最低限必要な単語数
          :database     => "albatro.db",
          :sample_at    => :first,  # 揺らぐとデバッグしにくいのでデフォルトは先頭を取得
        })
    end

    def help
      puts "tree"
      puts "clear"
      puts "load"
      puts "save"
    end

    def clear
      @dictionary = nil
    end

    def dictionary
      @dictionary ||= MarkovNode.new(:word => "(root)")
    end

    def tree(*args)
      dictionary.tree(*args)
    end

    def tree_dump
      dictionary.tree_dump(@options[:prefix])
    end

    def to_dot(options = {})
      dictionary.to_dot(options.merge(:prefix => @options[:prefix]))
    end

    def sentence_add(words)
      if words.size <= @options[:min_depth]
        return
      end
      prefixes = []
      words.size.times{|base_index|
        node = nil
        prefixes = (0..@options[:prefix]).collect{|index|words[base_index + index]}.compact
        Albatro.logger.debug([:sentence_add, base_index, prefixes].inspect) if Albatro.logger
        #
        # base_index prefixes
        #          0 ["アヒル", "と", "鴨"]
        #          1 ["と", "鴨", "の"]
        #          2 ["鴨", "の"]
        #          3 ["の"]
        #
        prefixes.each_with_index{|prefix_word, index|
          if index.zero?
            # プレフィクス1
            node = dictionary.nodes.find{|item|item.word == prefix_word} || dictionary.nodes_create(:word => prefix_word)
            if (base_index + index).zero?
              node.first_flag = true # "アヒル" のときだけフラグをつける
            end
          elsif (1...(prefixes.size-1)).include?(index)
            # プレフィクス2
            node = node.nodes.find{|item|item.word == prefix_word} || node.nodes_create(:word => prefix_word)
          else
            # サフィックス
            # ここを複数にした場合     → メモリ使用量大・多い言葉は選ばれやすくなる
            # ここをユニークにした場合 → メモリ使用量少・均等に選ばれる
            if options[:uniquesuffix]
              node = node.nodes.find{|item|item.word == prefix_word} || node.nodes_create(:word => prefix_word)
            else
              node.nodes_create(:word => prefix_word)
            end
          end
        }
      }
      # p MarkovNode.all.collect{|record|[record.id, record.word, record.node_ids, record.first_flag]}
    end

    #
    # 返事を返す
    #
    def dialogue(input, options = {})
      dialogue2(options.merge(:input => input))
    end

    #
    # 返事を返す(新しいインターフェイス)
    #
    def dialogue2(options = {})
      options = {
      }.merge(options)

      # 常に新しい話題を返す
      if options[:always_newtopic]
        return generate(options)
      end

      # TODO: ここもうちょっとよく考えた方がいい。(t)がついてない場合、新しく文章をつくるのではなく、(t)がついてないところから開始すればいい。
      keywords = Morpheme.instance.pickup_keywords(options[:input], :pickup => ["名詞", "形容詞"])  # 文の最初に使える語彙を相手の発言から探す
      # keywords = keywords.shuffle                                   # TODO: シャッフルする(ここまずい)
      if keyword = keywords.find{|keyword|first_node_find(keyword)} # 木構造のルートの下からマッチするものがあるか探す
        res = sentence_build(first_node_find(keyword), options)     # あればそこから文章を作る
      end

      if options[:rescue_silent]
        # 文章が作れなかったら自動生成する
        unless res
          res = generate(options)
        end
      end
      res
    end

    #
    # 自由に発言する
    #
    def generate(options = {})
      sentence_build(first_node_random(options), options)
    end

    #
    # 辞書を探索していく
    #
    def sentence_build(node, options = {})
      options = {
        :chain_max => 256, # 最大単語数
        :prefix => @options[:prefix],
      }.merge(options)

      if options[:prefix] > @options[:prefix]
        raise ArgumentError, "プレフィクスは#{@options[:prefix]+1}の木なので#{options[:prefix]}は無理です"
      end

      unless node
        return
      end

      complete = false
      collection = []
      slide_prefixes = []
      collection_set(collection, node)
      slide_prefixes << node

      # 次の言葉もランダムに決める
      (options[:prefix] - 1).times{
        next_node = node_sample(node.nodes, options)
        unless next_node
          # あまりに短い文章になってしまうけど完成したことにする
          complete = true
          break
        end
        slide_prefixes << next_node
        collection_set(collection, next_node)
        node = next_node
      }

      unless complete
        # あとはずらして行きながら特定していく
        options[:chain_max].times{|chain_index|
          next_slide_prefixes = []
          node = dictionary
          slide_prefixes.each_with_index{|current_prefix, index|
            node = node.nodes.find{|elem|elem.word == current_prefix.word}
            unless index.zero?
              next_slide_prefixes << node
            end
          }
          # 選択するノードがないので終了
          if node.nodes.empty?
            break
          end
          node = node_sample(node.nodes, options.merge(:collection => collection))
          # ノードが選択できなかったら終了
          unless node
            break
          end
          next_slide_prefixes << node
          collection_set(collection, node)
          slide_prefixes = next_slide_prefixes
        }
      end

      collection.collect{|node|node.word}
    end

    #
    # 文字列から学習
    #
    def study_from_string(str)
      Morpheme.instance.text_to_sentences(str).each{|sentence|
        Albatro.logger.debug("学習: #{sentence}") if Albatro.logger
        parts = Morpheme.instance.analyze(sentence)
        parts = Morpheme.instance.touten_reject(parts)
        parts = Morpheme.instance.kuten_reject(parts)
        parts = Morpheme.instance.keyword_connect(parts)
        Albatro.logger.debug("#{sentence.inspect} => #{parts.inspect}") if Albatro.logger
        words = parts.collect{|part|part[:word]}
        sentence_add(words)
      }
    end

    def info
      "#{self.class.name} 単語数:#{word_count} 先頭単語:#{dictionary.first_nodes.size} DB:#{database.basename}"
    end

    #
    # 単語数
    #
    #   -1 しているのは root があるから
    #
    def word_count
      dictionary.to_a.flatten.size - 1
    end

    def database
      Pathname(@options[:database]).expand_path
    end

    def save
      FileUtils.makedirs(database.dirname)
      database.open("w"){|f|f << Marshal.dump(dictionary)}
      Albatro.logger.debug("save: #{database.basename} #{info}") if Albatro.logger
    end

    def load
      @dictionary = Marshal.load(database.read)
      Albatro.logger.debug("load: #{database.basename} #{info}") if Albatro.logger
    end

    #
    # 最初に使える言葉たち
    #
    def first_words
      dictionary.first_nodes.collect{|elem|elem.word}
    end

    private

    #
    # 言及するために最初の言葉を決める
    #
    def first_node_find(word)
      dictionary.first_nodes.find{|elem|elem.word == word}
    end

    #
    # 辞書からランダムに最初の言葉を選ぶ
    #
    def first_node_random(options)
      node_sample(dictionary.first_nodes, options)
    end

    # 複数のノードから一つを選択する
    #
    # このメソッドで性格が変わるので、クラス化するのもあり
    #
    def node_sample(nodes, options)
      array_sample(nodes, :sample_at => options[:sample_at] || @options[:sample_at])
    end

    #
    # 文章を作るごとにその単語の選択回数を増やす
    #
    def collection_set(collection, node)
      collection << node
    end

    #
    # 実験用便利モジュール
    #
    module Utils
      def gather_newstopics(count = 256, options = {})
        responses = (0...count).collect{dialogue2(options.merge(:always_newtopic => true))}.compact.uniq
        responses.collect{|response|response.to_s}
      end
    end

    include Utils
  end

  class MarkovResponder < MarkovBaseResponder
    # 複数のノードから一つを選択する
    # このメソッドで性格が変わるので、クラス化するのもあり
    def node_sample(nodes, options)
      node = nil
      try_count = 0

      if options.blank?
        raise ArgumentError, "options が空です"
      end

      # TODO: 同じものを選択し続けないようにループに入らないようにチェックする
      # ループするたびに次のノードを選択するようにする
      sorted_nodes = nodes_sort(nodes, options)
      # p [options, sorted_nodes]
      node = sorted_nodes[try_count.modulo(sorted_nodes.size)]

      node
    end

    # 複数のノードをソートする
    #
    # options[:nodes_sort_type] が有効な場合
    #   selected_count が同じもの同士はランダム
    #
    # options[:nodes_sort_type] が有効でない場合
    #   selected_count が同じもの同士は生成順
    #
    def nodes_sort(nodes, options)
      nodes.sort_by{|node|
        if options[:nodes_sort_type].kind_of? Proc
          options[:nodes_sort_type].call(node)
        elsif options[:nodes_sort_type] == :rand
          [node.selected_count, rand]
        else
          [node.selected_count, node.id]
        end
      }
    end

    # 文章を作るごとにその単語の選択回数を増やす
    def collection_set(collection, node)
      super
      node.selected_count += 1
    end
  end
end

if $0 == __FILE__
  str = "AとBとC"
  object = Albatro::MarkovResponder.new(:prefix => 2)
  object.study_from(:string => str)
  p object.dialogue2(:input => "A", :always_newtopic => true, :chain_max => 10, :prefix => 1).to_s
  puts object.tree
  exit

  pp object.dialogue2(:always_newtopic => true, :chain_max => 10).to_s

  # object = Albatro::MarkovResponder.new(options.merge(:sample_try_max => 0))
  # object.study_from(:string => str)
  # pp object.dialogue2(:always_newtopic => true, :chain_max => 4)
  # object.study_from_stream(:file =>)
  # pp object.gather_newstopics
  #
  # exit

  str = "AとAとB"
  object = Albatro::MarkovBaseResponder.new(:prefix => 1)
  object.study_from(:string => str)
  pp object.dialogue2(:always_newtopic => true, :chain_max => 10).to_s

  object = Albatro::MarkovResponder.new(:prefix => 1)
  object.study_from(:string => str)
  pp object.dialogue2(:always_newtopic => true, :chain_max => 10).to_s

  exit

  pp object.gather_newstopics(1, :word_count)

  exit

  object = Albatro::MarkovResponder.new
  # object.study_from(:file => "resources/usagi.txt")
  object.study_from(:text => "AとBとC")
  puts object.tree
  words = object.generate

  # puts object.tree
  # 10.times{
  #   puts object.generate.to_s
  # }
  # exit

  # object.sentence_build2(words)
  # exit

  # Albatro::MarkovResponder.new.interactive

  prefix = 3

  Albatro::Morpheme.instance.analyze_display("おもしろいゲーム")

  # first = "A"
  # strs = [
  #   "Aは速いBでしょ",
  #   # "Aが速いCだ",
  #   "Aが速いBです",
  # ]

  # first = "おもしろい"

  strs = [
    "おもしろいゲームはドラクエです",
    "つまらないゲームはテトリスです",
    "主食はスパゲティです",
  ]
  # object = Albatro::MarkovResponder.new
  object = Albatro::MarkovResponder.new(:prefix => prefix)
  strs.each{|str|
    Albatro::Morpheme.instance.analyze_display(str)
    object.study_from_string(str)
  }
  strs2 = []
  1000.times{|i|
    if str = object.dialogue(object.first_words.sample)
      str = str.to_s
      if strs.include?(str) || strs2.include?(str)
        next
      end
      puts str
      strs2 << str
    end
  }
  puts object.tree
  exit

  puts object.tree

  # +------------+-------------+
  # | 語彙       | 意味        |
  # +------------+-------------+
  # | おもしろい | 形容詞 自立 |
  # | ゲーム     | 名詞 一般   |
  # +------------+-------------+
  # +------------+-------------+
  # | 語彙       | 意味        |
  # +------------+-------------+
  # | おもしろい | 形容詞 自立 |
  # | ゲーム     | 名詞 一般   |
  # | は         | 助詞 係助詞 |
  # | ドラクエ   | 名詞 一般   |
  # | です       | 助動詞      |
  # +------------+-------------+
  # +------------+-------------+
  # | 語彙       | 意味        |
  # +------------+-------------+
  # | つまらない | 形容詞 自立 |
  # | ゲーム     | 名詞 一般   |
  # | は         | 助詞 係助詞 |
  # | テトリス   | 名詞 一般   |
  # | です       | 助動詞      |
  # +------------+-------------+
  # おもしろいゲームはテトリスです
  # (root)
  # ├─おもしろい(t)
  # │  └─ゲーム
  # │      └─は
  # ├─ゲーム
  # │  └─は
  # │      ├─ドラクエ
  # │      └─テトリス
  # ├─は
  # │  ├─ドラクエ
  # │  │  └─です
  # │  └─テトリス
  # │      └─です
  # ├─ドラクエ
  # │  └─です
  # ├─です
  # ├─つまらない(t)
  # │  └─ゲーム
  # │      └─は
  # └─テトリス
  #     └─です

  # p object.dialogue("お好み焼き")
  exit

  object = Albatro::MarkovResponder.new(:database => "_test.db")
  object.clear
  # Morpheme.instance.analyze_display("スーパーお好み焼きが食べたい", :connect => true)
  object.study_from_string("スーパーお好み焼きが食べたい")
  p object.dialogue("お好み焼き")
  exit

  object.study_from_string("ドイツ卓球協会とは？")
  object.sentence_add(["私", "は", "鳥", "に", "なる"])
  puts object.tree
  p object.generate

  object = Albatro::MarkovResponder.new
  object.study_from_stream(:file => "resources/butaniku.txt")
  puts object.tree
  10.times{
    object.generate
  }
end
