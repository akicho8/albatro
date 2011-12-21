# -*- coding: utf-8 -*-

require "kconv"

module Albatro
  module TreeSupport
    def tree(options = {}, &block)
      options = {
        # オプション相当
        :skip             => 0,     # 何レベルスキップするか？(1にするとrootを表示しない)
        :root_label       => nil,   # ルートを表示する場合に有効な代替ラベル
        :tab_space        => 4,     # 途中からのインデント幅
        :connect_char     => "├",
        :tab_visible_char => "│",
        :edge_char        => "└",
        :branch_char      => "─",
        :debug            => false, # わけがわからなくなったら true にしよう
        # テンポラリ
        :depth            => [],
      }.merge(options)

      if options[:depth].size > options[:skip]
        if self == parent.nodes.last
          prefix_char = options[:edge_char]
        else
          prefix_char = options[:connect_char]
        end
      else
        prefix_char = ""
      end

      indents = options[:depth].enum_with_index.collect{|flag, index|
        if index > options[:skip]
          tab = flag ? options[:tab_visible_char] : ""
          tab.toeuc.ljust(options[:tab_space]).toutf8
        end
      }

      if block_given?
        label = yield(self, options[:depth])
      else
        if options[:depth].empty? && options[:root_label] # ルートかつ代替ラベルがあれば変更
          label = options[:root_label]
        else
          label = to_s_for_tree
        end
      end

      branch_char = nil
      if options[:depth].size > options[:skip]
        branch_char = options[:branch_char]
      end

      if options[:depth].size >= options[:skip]
        buffer = "#{indents}#{prefix_char}#{branch_char}#{label}#{options[:debug] ? options[:depth].inspect : ""}\n"
      else
        buffer = ""
      end

      flag = false
      if parent
        flag = (self != parent.nodes.last)
      end

      options[:depth].push(flag)
      buffer << nodes.collect{|node|node.tree(options)}.to_s
      options[:depth].pop

      buffer
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

  puts root.tree(:skip => 0)
  puts root.tree(:skip => 0, :root_label => "トップ")
  puts root.tree(:skip => 1, :root_label => "トップ")
end
