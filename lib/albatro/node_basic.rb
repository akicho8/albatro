# -*- coding: utf-8 -*-

module Albatro
  #
  # 汎用ツリー構造
  #
  # データを保持するにはクラスを継承
  #
  class NodeBasic
    attr_reader :nodes

    def initialize(*)
      @nodes = []
    end

    # ちょっと詳しい文字列表現
    def to_s_for_tree
      "#{object_id}"
    end

    # シンプルな文字列表現
    def simple_value
      "#{object_id}"
    end

    # 配列化
    def to_a
      [self, @nodes.collect{|node|node.to_a}]
    end

    # 子の作成
    def nodes_create(params = {})
      node = self.class.new(params)
      node.parent = self
      @nodes << node
      node
    end

    protected

    attr_accessor :parent
  end
end

if $0 == __FILE__
  root = Albatro::NodeBasic.new
  node1 = root.nodes_create
  node4 = root.nodes_create
  node5 = node4.nodes_create
  node2 = node1.nodes_create
  node3 = node1.nodes_create
  node2.nodes_create
  node2.nodes_create
  puts root.to_a
end
