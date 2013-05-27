# -*- coding: utf-8 -*-
require "spec_helper"
require "albatro/responder/memory_responder"

describe Responder::MemoryResponder do
  it "聞いて相手が答えた内容を記憶する" do
    responder = Responder::MemoryResponder.new
    responder.dialogue("夢の中で会ったような…").should == "夢の中って？"
    responder.dialogue("輪廻のこと").should == "なるほど"
    responder.dialogue("夢の中とは").should == "輪廻のこと"
  end
end
