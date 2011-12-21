# -*- coding: utf-8 -*-
require "spec_helper"
require "albatro/simple_node"

describe Albatro::SimpleNode do
  before do
    @root = Albatro::SimpleNode.new(:word => "(root)")
    node1 = @root.nodes_create(:word => "アヒル")
    node4 = @root.nodes_create(:word => "チルドレン")
    node5 = node4.nodes_create(:word => "です")
    node2 = node1.nodes_create(:word => "と")
    node3 = node1.nodes_create(:word => "です")
    node2.nodes_create(:word => "ピエロ")
    node2.nodes_create(:word => "カモ")
  end

  it "SimpleNode は word 属性を持ち、tree と to_dot に対応している" do
    @root.tree.should be_present
    @root.to_dot.should be_present
  end
end
