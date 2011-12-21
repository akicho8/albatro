# -*- coding: utf-8 -*-
require "spec_helper"
require "albatro/net_responder"

describe Albatro::NetResponder do
  before do
    @responder = Albatro::NetResponder.new(:mock => true)
  end

  it "dialogue" do
    @responder.dialogue("初音ミクの画像ください").should be_present
    @responder.dialogue("伊坂幸太郎の本が欲しい").should be_present
    @responder.dialogue("自炊の本が欲しい").should be_present
    @responder.dialogue("卓球台が欲しい").should be_present
    @responder.dialogue("石原慎太郎とは誰ですか").should be_present
    @responder.dialogue("初音ミクとは何ですか").should be_present
    @responder.dialogue("明日の天気だいじょうぶかな").should be_present
  end
end
