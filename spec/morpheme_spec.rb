# -*- coding: utf-8 -*-
require "spec_helper"
require "albatro/morpheme"

describe Albatro::Morpheme do
  before do
    @object = Albatro::Morpheme.instance
  end

  it "analyze" do
    @object.analyze("しかし、私は、プログラムです。").should == [{:senses=>["接続詞"], :word=>"しかし"}, {:senses=>["記号", "読点"], :word=>"、"}, {:senses=>["名詞", "代名詞", "一般"], :word=>"私"}, {:senses=>["助詞", "係助詞"], :word=>"は"}, {:senses=>["記号", "読点"], :word=>"、"}, {:senses=>["名詞", "サ変接続"], :word=>"プログラム"}, {:senses=>["助動詞"], :word=>"です"}, {:senses=>["記号", "句点"], :word=>"。"}]
    @object.analyze("終った。").should == [{:senses=>["動詞", "自立"], :word=>"終っ"}, {:senses=>["助動詞"], :word=>"た"}, {:senses=>["記号", "句点"], :word=>"。"}]
    @object.analyze("もうだめだ。").should == [{:senses=>["副詞", "一般"], :word=>"もう"}, {:senses=>["名詞", "形容動詞語幹"], :word=>"だめ"}, {:senses=>["助動詞"], :word=>"だ"}, {:senses=>["記号", "句点"], :word=>"。"}]
  end

  describe Albatro::Morpheme::Utils do
    it "__keyword" do
      @object.__keyword?({:senses => ["名詞", "代名詞", "一般"], :word => "私"}).should be_true
    end

    it "pickup_keywords" do
      @object.pickup_keywords("夏花火と冬花火").should == ["夏花火", "冬花火"]
      @object.pickup_keywords("初音ミクと鏡音リン").should == ["初音ミク", "鏡音リン"]
      @object.pickup_keywords("ドビュッシーとパスタが好きです", :reject => ["形容動詞語幹"]).should == ["ドビュッシー", "パスタ"]
    end

    it "keyword_connect" do
      @object.keyword_connect(@object.analyze("夏花火と冬花火")).should == [
        {:senses => ["名詞", "固有名詞", "人名", "姓", "一般"], :word => "夏花火"},
        {:senses => ["助詞", "並立助詞"],                       :word => "と"},
        {:senses => ["名詞", "一般"],                           :word => "冬花火"},
      ]
    end

    it "テキストを行毎に分解できる" do
      @object.text_to_sentences("です\nそれと").should == ["です", "それと"]
    end

    it "「？！。」があるとそこで文章が区切られる" do
      @object.text_to_sentences("あ！？これ！です。おわり").should == ["あ！？", "これ！", "です。", "おわり"]
    end

    it "読点を削除できる" do
      {
        "僕は、" => "僕は",
        "僕が、" => "僕が",
        "で、"   => "で、",
      }.each{|src, dst|
        @object.touten_reject(@object.analyze(src)).collect{|e|e[:word]}.to_s.should == dst
      }
    end

    it "句点を削除できる" do
      {
        "です。"     => "です",
        "します。"   => "します",
        "しました。" => "しました",
        "ですね。"   => "ですね",
        "している。" => "している",
        "私。"       => "私。",
      }.each{|src, dst|
        @object.kuten_reject(@object.analyze(src)).collect{|e|e[:word]}.to_s.should == dst
      }
    end
  end
end
