# -*- coding: utf-8 -*-
require "spec_helper"
require "albatro/responder/ask_responder"

describe Responder::AskResponder do
  before do
    @responder = Responder::AskResponder.new
  end

  it "赤ちゃんなのでオウム返しする" do
    @responder.dialogue("大切な人").should == "大切な人って？"
    @responder.dialogue("とっても大切な人").should == "とっても大切な人って？"
    @responder.dialogue("弱い私がいる").should == "弱い私って？"
    @responder.dialogue("大規模なデータ").should == "大規模なデータって？"
  end
end
