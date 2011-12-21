# -*- coding: utf-8 -*-
#
# 継承して独自のデータを保持する例
# テスト用のクラス
# このクラスを作っておかないとテストしにくい
#
require File.expand_path(File.join(File.dirname(__FILE__), "node_base"))

module Albatro
  class SimpleNode < NodeBase
    def initialize(params = {})
      super
      @word = params[:word]
    end

    def to_s_for_tree
      @word
    end

    def simple_value
      @word
    end
  end
end

if $0 == __FILE__
  root = Albatro::SimpleNode.new(:word => "(root)")
  node1 = root.nodes_create(:word => "アヒル")
  node4 = root.nodes_create(:word => "チルドレン")
  node5 = node4.nodes_create(:word => "です")
  node2 = node1.nodes_create(:word => "と")
  node3 = node1.nodes_create(:word => "です")
  node2.nodes_create(:word => "ピエロ")
  node2.nodes_create(:word => "カモ")
  puts root.tree
end
