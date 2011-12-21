# -*- coding: utf-8 -*-
require "spec_helper"
require "albatro/memory_responder"

describe Albatro::MemoryResponder do
  it "聞いて相手が答えた内容を記憶する" do
    responder = Albatro::MemoryResponder.new
    responder.dialogue("夢の中で会ったような…").should == "夢の中って？"
    responder.dialogue("輪廻のこと").should == "なるほど"
    responder.dialogue("夢の中とは").should == "輪廻のこと"
  end
end
