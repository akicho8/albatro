# -*- coding: utf-8 -*-
require "spec_helper"
require "MeCab"

describe MeCab do
  it "バージョンが取得できる" do
    MeCab::VERSION.should be_present
  end

  it "メモリが多い場合のパース" do
    parser = MeCab::Tagger.new("-Ochasen")
    parser.parse("青空の下で読書").should be_present
  end

  it "メモリが少ない場合のパース" do
    parser = MeCab::Tagger.new("-Ochasen")
    it = parser.parseToNode("青空の下で読書")
    while it do
      [it.surface, it.feature, it.cost]
      it = it.next
    end
  end

  it "オプションの試行錯誤用" do
    mecab_parse("儚い青空の下で読書", "--cost-factor=800")
    mecab_parse("儚い青空の下で読書", "--cost-factor=1")
  end

  private

  # オプションの試行錯誤用
  def mecab_parse(str, options)
    # puts MeCab::Tagger.new("-d /opt/local/lib/mecab/dic/ipadic-utf8 -Ochasen #{options}").parse(str)
  end
end
