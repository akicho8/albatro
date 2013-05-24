# -*- coding: utf-8 -*-
require "spec_helper"
require "albatro/simple_node"

describe Albatro::GraphvizSupport do
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

  after do
    # Pathname.glob("tmp/__tmp_output*.png").each{|filename|FileUtils.rm(filename)}
  end

  it "to_dot" do
    @root.to_dot(:binary => true)
    @root.to_dot(:file => "tmp/__tmp_output1.png", :root_display => true)
    @root.to_dot(:file => "tmp/__tmp_output2.png", :root_display => true, :root_label => "トップ")
    @root.to_dot(:file => "tmp/__tmp_output3.png", :root_display => false)
  end
end
