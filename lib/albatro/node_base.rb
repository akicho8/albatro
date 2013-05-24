require_relative "node_basic"
require_relative "graphviz_support"

module Albatro
  class NodeBase < NodeBasic
    include TreeSupport::Model
    include GraphvizSupport
  end
end

if $0 == __FILE__
  root = Albatro::NodeBase.new
  node1 = root.nodes_create
  node4 = root.nodes_create
  node5 = node4.nodes_create
  node2 = node1.nodes_create
  node3 = node1.nodes_create
  node2.nodes_create
  node2.nodes_create
  puts root.tree
end
