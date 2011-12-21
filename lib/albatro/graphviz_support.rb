# -*- coding: utf-8 -*-
require "fileutils"
require "pathname"

module Albatro
  module GraphvizSupport
    def initialize(*)
      super
      @@gv_auto_index ||= 0
      @@gv_auto_index += 1
      @gv_id = @@gv_auto_index
    end

    #
    # 文字列やPNGやバイナリを返す
    #
    #   to_dot                        #=> dot_as_string と同等
    #   to_dot(:binary => true)       #=> pngの中身
    #   to_dot(:file => "output.png") #=> "output.png" の出力
    #
    def to_dot(options = {})
      case
      when options[:binary]
        dot_as_binary(options)
      when options[:file]
        dot_as_file(options[:file], options)
      else
        dot_as_string(options)
      end
    end

    protected

    # ノードの文字列
    # オーバーライド必須
    def dot_label_attrs(options = {})
      attrs = {}
      attrs[:label] = (options[:label] || simple_value).to_s.gsub(/"/, "\\\"")
      attrs
    end

    # 自分からtargetを指す矢印
    # オーバーライドしたかったらどうぞ
    def dot_edge_attrs(target, options = {})
      {}
    end

    # graphviz用のユニークなノード名
    # オーバーライド禁止
    def dot_node_name
      "n#{@gv_id}"
    end

    # graphviz用のラベル
    # オーバーライド禁止
    def dot_label_name(options = {})
      %{#{dot_node_name} [#{dot_params_to_s(dot_label_attrs(options))}];}
    end

    # dot表記の文字列を返す
    #
    # 例:
    #
    #   digraph sample {
    #     graph [charset="UTF-8", ranksep=0.2, size="10.0,10.0", rankdir=LR];
    #     node [fontsize=20, fontname="azukiP"]
    #     root -> n1 -> n2 -> n3;
    #     root -> n4 -> n5 -> n6;
    #     root -> n7 -> n8 -> n9;
    #     n1  [label="私"];
    #     n2  [label="は"];
    #     n3  [label="ファミコン"];
    #     n4  [label="は"];
    #     n5  [label="ファミコン"];
    #     n6  [label="です"];
    #     n7  [label="ファミコン"];
    #     n8  [label="です"];
    #     n9  [label="。"];
    #   }
    #
    def dot_as_string(options = {})
      options = {
        # dot_as_string 自身のオプション
        :root_display => true, # 自分を含めるか？
        :root_label => nil,    # 自分を含める場合に指定すると名前を変更できる
        # テンポラリ
        :depth => 0,
        # graphviz の設定
        :charset     => "UTF-8",  # 文字コード(日本語を使う場合はこれ必須)
        :fontname    => "azukiP", # ノードのフォント(あずきプロポーショナル)
        :rankdir     => "LR",     # グラフの向き
        :ranksep     => nil,      # ノードのレベル毎の間隔
        :nodesep     => nil,      # ノードとノードの間隔
        :size        => nil,      # グラフ全体の大きさ。"10.0,10.0" のように指定。1.0 = 2.54センチ
        :fontsize    => nil,      # ノードのフォントサイズ
        :concentrate => true,     # エッジが重なりそうな場合、束ねるか？
        :labelloc    => "t",      # グラフのラベルをつけるとしたらどこに？(t=上)
      }.merge(options)
      out = []
      if options[:depth] == 0
        out << "digraph g#{object_id} {"
        graph = dot_params_build(options, [:labelloc, :fontname, :charset, :ranksep, :nodesep, :size, :rankdir, :graph_label, :concentrate], {:graph_label => :label})
        node  = dot_params_build(options, [:fontname, :fontsize])
        out << "  graph [#{graph}];"
        out << "  node [#{node}];"
        if options[:root_display]
          out << "  " + dot_label_name(options.merge(:label => options[:root_label]))
        end
      end
      @nodes.each{|node|
        out << "  " + node.dot_label_name(options)
        if options[:root_display] || options[:depth] >= 1
          out << "  #{dot_node_name} -> #{node.dot_node_name} [#{dot_params_to_s(dot_edge_attrs(node, options))}];"
        end
        out << node.dot_as_string(options.merge(:depth => options[:depth].next))
      }
      if options[:depth] == 0
        out << "}"
        out.flatten.join("\n")
      else
        out
      end
    end

    private

    #
    # バイナリを返す
    #
    #   dot_as_binary => "PNG......"
    #
    def dot_as_binary(options = {})
      options = {
        :format => "png",
      }.merge(options)
      IO.popen("dot -q -T#{options[:format]}", "w+"){|io|
        io.puts dot_as_string(options)
        io.close_write
        io.read
      }
    end

    #
    # ファイルに出力
    #
    #   dot_as_string("output.png")
    #
    def dot_as_file(filename, options = {})
      filename = Pathname(filename).expand_path
      unless filename.extname.match(/(png|jpg|gif)/)
        raise ArgumentError, "#{filename} の拡張子を画像の拡張子にしてください"
      end
      FileUtils.makedirs(filename.dirname)
      filename.open("w"){|f|f << dot_as_binary(options)}
    end

    def dot_params_build(options, keys, table = {})
      hash = {}
      keys.each{|key|
        unless options[key].nil?
          hash[table[key] || key] = options[key]
        end
      }
      dot_params_to_s(hash)
    end

    def dot_params_to_s(hash)
      hash.collect{|k, v|"#{k}=\"#{v}\""}.join(", ")
    end
  end
end

if $0 == __FILE__
  require "simple_node"

  root = Albatro::SimpleNode.new(:word => "(root)")
  node1 = root.nodes_create(:word => "アヒル")
  node4 = root.nodes_create(:word => "チルドレン")
  node5 = node4.nodes_create(:word => "です")
  node2 = node1.nodes_create(:word => "と")
  node3 = node1.nodes_create(:word => "です")
  node2.nodes_create(:word => "ピエロ")
  node2.nodes_create(:word => "カモ")
  # puts root.tree

  root.to_dot(:binary => true)
  root.to_dot(:file => "_output1.png", :root_display => true)
  root.to_dot(:file => "_output2.png", :root_display => true, :root_label => "トップ")
  root.to_dot(:file => "_output3.png", :root_display => false)
  root.to_dot(:file => "_output4.png", :root_display => false, :graph_label => "グラフのラベル")
  # puts root.to_dot
end
