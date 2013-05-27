# -*- coding: utf-8 -*-
require "spec_helper"
require "albatro/responder/markov_responder"

describe Responder::MarkovResponder do
  before do
    @zero_responder = Responder::MarkovResponder.new
  end

  it "文章を学習していける" do
    @zero_responder.sentence_add(["私", "は", "鳥", "に", "なる"])
    @zero_responder.dialogue("私").join.should == "私は鳥になる"
    @zero_responder.sentence_add(["僕", "は", "鳥", "に", "変身"])
    @zero_responder.dialogue("私", :sample_at => :last).join.should == "私は鳥に変身"
    @zero_responder.dialogue("僕", :sample_at => :first).join.should == "僕は鳥になる"
    @zero_responder.sentence_add(["変身", "する"])
    # @zero_responder.tree
  end

  it "深さ1の場合はスキップされる" do
    @zero_responder.sentence_add(["私"])
    # p @zero_responder.tree
    @zero_responder.dialogue("私").should be_nil
  end

  it "ファイルから学習できる" do
    @zero_responder.study_from(:file => "#{File.dirname(__FILE__)}/../resources/bocchan_mini.txt")
    @zero_responder.tree.should match(/無鉄砲/)
    @zero_responder.dialogue2(:always_newtopic => true).should be_an_instance_of Array
  end

  describe "サフィックスの重複について" do
    it "サフィックスをユニークにする場合" do
      responder = Responder::MarkovBaseResponder.new(:uniquesuffix => true)
      responder.study_from_string("アヒルと鴨")
      responder.study_from_string("アヒルと鴨")
      responder.tree_dump.should == {"鴨"=>{}, "と"=>{"鴨"=>[]}, "アヒル"=>{"と"=>["鴨"]}}
    end

    it "サフィックスに重複を許す場合" do
      responder = Responder::MarkovBaseResponder.new(:uniquesuffix => false)
      responder.study_from_string("アヒルと鴨")
      responder.study_from_string("アヒルと鴨")
      responder.tree_dump.should == {"鴨"=>{}, "と"=>{"鴨"=>[]}, "アヒル"=>{"と"=>["鴨", "鴨"]}}
    end
  end

  it "dialogue" do
    responder = Responder::MarkovBaseResponder.new
    responder.study_from_string("アヒルと鴨")
    responder.dialogue("アヒル").should be_present
    responder.dialogue("鴨").should be_blank
    responder.dialogue2(:always_newtopic => true).should == ["アヒル", "と", "鴨"]
  end

  describe "選択したノードに歩いた回数をカウントしていくロジックについて" do
    before do
      @str = "XとAとB"
    end

    it "カウンタブルが効いてないのでAを何度も選択してしまう" do
      object = Responder::MarkovBaseResponder.new(:prefix => 1)
      object.study_from(:string => @str)
      object.dialogue2(:always_newtopic => true, :chain_max => 10).join.should == "XとAとAとAとAとA"
    end

    it "カウンタブルが効いているのでAのあとはBを選択する" do
      object = Responder::MarkovResponder.new(:prefix => 1)
      object.study_from(:string => @str)
      object.dialogue2(:always_newtopic => true, :chain_max => 10).join.should == "XとAとB"
    end

    describe "歩いた回数が同じものは最初に登録されたものから選択するかどうか" do
      before do
        @lines = ["XとA", "XとB", "XとC"]
      end

      it "同じ selected_count なら最初に登録されたものから選択" do
        object = Responder::MarkovResponder.new(:prefix => 2)
        object.study_from(@lines)
        resp = (0...3).collect{object.dialogue2(:always_newtopic => true, :chain_max => 10, :nodes_sort_type => nil).join}
        resp.should == ["XとA", "XとB", "XとC"]
      end

      it "同じ selected_count なら最後に登録されたものから選択" do
        object = Responder::MarkovResponder.new(:prefix => 2)
        object.study_from(@lines)
        resp = (0...3).collect{object.dialogue2(:always_newtopic => true, :chain_max => 10, :nodes_sort_type => proc{|e|[e.selected_count, -e.id]}).join}
        resp.should == ["XとC", "XとB", "XとA"]
      end

      it "同じ selected_count ならランダム" do
        object = Responder::MarkovResponder.new(:prefix => 2)
        object.study_from(@lines)
        resp = (0...3).collect{object.dialogue2(:always_newtopic => true, :chain_max => 10, :nodes_sort_type => :rand).join}
        resp.should be_present
      end
    end
  end

  describe "勉強会用" do
    before do
      @messages_hash = {
        "m1" => [
          "おもしろいゲームはドラクエです",
          "つまらないゲームはテトリスです",
        ],
        "m2" => [
          "おもしろいゲームはドラクエです",
          "つまらないゲームはテトリスです",
          "主食はスパゲティです",
        ],
      }

      @markovs = {}
      (1..3).each{|prefix|
        @messages_hash.each{|mkey, messages|
          key = "p#{prefix}_#{mkey}"
          responder = Responder::MarkovResponder.new(:prefix => prefix)
          messages.each{|str|responder.study_from(str)}
          filename_prefix = File.expand_path(File.join(File.dirname(__FILE__), "_" + File.basename(__FILE__, '.*')))
          if false
            responder.to_dot(:root_label => "スタート", :file => "#{filename_prefix}_#{key}_ud.png", :rankdir => "UD", :fontsize => 14)
            responder.to_dot(:root_label => "スタート", :file => "#{filename_prefix}_#{key}_lr.png", :rankdir => "LR", :fontsize => 14)
          end
          @markovs[key] = responder
        }
      }
    end

    it "文章を作る - 単純マルコフでうまく行く" do
      [
        "おもしろいゲーム教えて",
        "他にもおもしろいゲームある？",
        "つまらないゲームは？",
        "さっきおもしろいゲームはドラクエって言わなかった？",
      ].collect{|input|@markovs["p1_m1"].dialogue(input).join}.should == [
        "おもしろいゲームはドラクエです",
        "おもしろいゲームはテトリスです",
        "つまらないゲームはドラクエです",
        "おもしろいゲームはテトリスです",
      ]
    end

    it "文章を作る - 単純マルコフの欠点 - 好きなゲームの一貫性がないがないのは揺らぎなのでいいとしても、ゲームと食べ物の区別がついていない" do
      [
        "おもしろいゲーム教えて",
        "他におもしろいゲームある？",
        "つまらないのは？",
        "ところで主食なんだっけ？",
      ].collect{|input|@markovs["p1_m2"].dialogue(input).join}.should == [
        "おもしろいゲームはドラクエです",
        "おもしろいゲームはテトリスです",
        "つまらないゲームはスパゲティです",
        "主食はドラクエです",
      ]
    end

    it "文章を作る - もう単純とは言わせない - 好きなゲームの一貫性がないが、ゲームと食べ物の区別ができるようになる" do
      [
        "おもしろいゲーム教えて",
        "他におもしろいゲームある？",
        "つまらないのは？",
        "ところで主食なんだっけ？",
      ].collect{|input|@markovs["p2_m2"].dialogue(input).join}.should == [
        "おもしろいゲームはドラクエです",
        "おもしろいゲームはテトリスです",
        "つまらないゲームはドラクエです",
        "主食はスパゲティです",
      ]
    end

    it "文章を作る - ぶれないマルコフ氏 - おもしろいゲームは一貫してドラクエ。テトリスではない" do
      [
        "おもしろいゲームある？",
        "他にもおもしろいゲームある？",
        "他におもしろいのある？",
        "じゃあ、つまらないのは？",
      ].collect{|input|@markovs["p3_m2"].dialogue(input).join}.should == [
        "おもしろいゲームはドラクエです",
        "おもしろいゲームはドラクエです",
        "おもしろいゲームはドラクエです",
        "つまらないゲームはテトリスです",
      ]
    end
  end
end
