# -*- coding: utf-8 -*-
require_relative "node_base"

module Albatro
  module AutoIndex
    attr_accessor :id

    def initialize(*)
      super
      # 動作確認用
      @@auto_index ||= 0
      @id = @@auto_index
      @@auto_index += 1
    end
  end

  #
  # マルコフさん用ノード
  #
  class MarkovNode < NodeBase
    include AutoIndex

    attr_reader :word

    # 「秋刀魚の季節です」の文章なら「秋刀魚」だけにフラグが付く
    # このフラグは選ばれやすくするために使う
    # 選ばれると長い文章を生成できる
    attr_accessor :first_flag

    # 選ばれた回数をカウントする
    attr_accessor :selected_count

    def initialize(params = {})
      super
      @word = params[:word]
      @first_flag = params[:first_flag]
      @selected_count ||= 0
    end

    # ノードを一行で表わす
    def to_s_tree
      flags = []
      if first_flag
        flags << "t"
      end
      unless flags.empty?
        flags = "(" + flags.join + ")"
      end
      str = "#{@id}:#{simple_value}#{flags}"
      if str
        str = "#{str}(#{@selected_count})"
      end
      str
    end

    def simple_value
      @word
    end

    # 文章の先頭として使えるノードたち取得
    def first_nodes
      children.find_all{|node|node.first_flag}
    end

    # デバッグ用にシンプルなruby形式の辞書に変換
    #
    #   @root = MarkovNode.new(:word => "(root)")
    #   node1 = @root.nodes_create(:word => "アヒル")
    #   node2 = node1.nodes_create(:word => "と")
    #   node2.nodes_create(:word => "鴨")
    #   node2.nodes_create(:word => "カモ")
    #   node1.nodes_create(:word => "が")
    #   @root.tree_dump(2) #=> {"アヒル"=>{"と"=>["鴨", "カモ"], "が"=>[]}}
    #
    def tree_dump(prefix_size, _depth = 0)
      if _depth == prefix_size
        result = []
      else
        result = {}
      end
      children.each{|node|
        if _depth == prefix_size
          result << node.word
        else
          result[node.word] = node.tree_dump(prefix_size, _depth.next)
        end
      }
      result
    end

    #
    # Graphvizの表示をもっと綺麗にする
    #
    def dot_label_attrs(options = {})
      attrs = super
      if first_flag
        attrs[:style] = "filled"
        attrs[:color] = "black"
        attrs[:fillcolor] = "lightblue"
      end
      # if options[:prefix] && options[:prefix] == options[:depth] && (parent && parent.children.size > 1) # 一番最後で兄弟がいる
      if options[:depth] >= 1 && (parent && parent.children.size > 1) # 兄弟がいる
        attrs[:style] = "filled"
        attrs[:color] = "black"
        attrs[:fillcolor] = "lightpink"
      end
      attrs
    end

    #
    # 自分 -> target のエッジ
    #
    def dot_edge_attrs(target, options = {})
      attrs = super
      if options[:depth] == 0 && !target.first_flag
        # 有効にするとRootから選択することのない最初のノードへの線がダッシュになる
        # attrs[:style] = "dashed"
      end
      attrs
    end

    def inspect
      "#{@id}:#{@word}(#{@selected_count})"
    end
  end
end

if $0 == __FILE__
  @root = Albatro::MarkovNode.new(:word => "(root)")
  node1 = @root.nodes_create(:word => "アヒル")
  node2 = node1.nodes_create(:word => "と")
  node2.nodes_create(:word => "鴨")
  node2.nodes_create(:word => "カモ")
  node1.nodes_create(:word => "が")
  # p @root.tree_dump(2)
  puts @root.tree
  puts @root.to_dot
  @root.to_dot(:file => "_output.png")
  exit

  @root = Albatro::MarkovNode.new
  a = @root.nodes_create
  a.nodes_create
  b = a.nodes_create
  c = b.nodes_create
  c.nodes_create
  b.nodes_create
  @root.nodes_create

  print @root.tree
  # /-node1
  #     ├-node2
  #     │ ├-node3
  #     │ └-node4
  #     └-node5
  print a.tree
  # ├-node2
  # │ ├-node3
  # │ └-node4
end
