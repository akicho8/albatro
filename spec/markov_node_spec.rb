# -*- coding: utf-8 -*-
require "spec_helper"
require "albatro/markov_node"

describe Albatro::MarkovNode do
  it "basic" do
    root = Albatro::MarkovNode.new(:word => "(root)")
    node1 = root.nodes_create(:word => "アヒル")
    node2 = node1.nodes_create(:word => "と")
    node2.nodes_create(:word => "鴨")
    node2.nodes_create(:word => "カモ")
    node1.nodes_create(:word => "が")
    root.tree_dump(2).should == {"アヒル"=>{"と"=>["鴨", "カモ"], "が"=>[]}}
    root.tree.should be_present
    root.nodes.should be_present
  end
end
