# -*- coding: utf-8 -*-
require "spec_helper"
require "albatro/log_responder"

describe Albatro::LogResponder do
  it "ログから会話を盗む" do
    responder = Albatro::LogResponder.new
    responder.study_from_string("x")
    responder.study_from_string("返答0")
    responder.study_from_string("a")
    responder.study_from_string("返答1")
    responder.study_from_string("aとb")
    responder.study_from_string("返答2")
    responder.study_from_string("aとbとc")
    responder.study_from_string("返答3")
    responder.dialogue("aとb").should == "返答2"
    responder.last_hash.should == {6 => 2, 2 => 1, 4 => 2}
    responder.last_sorted_hash.should == [[4, 2], [6, 2], [2, 1]]
  end

  it "実例" do
    responder = Albatro::LogResponder.new
    responder.study_from_string("卓球でもやるか")
    responder.study_from_string("やろうやろう")
    responder.study_from_string("テレ東の世界卓球への力の入れ具合いは異常")
    responder.study_from_string("興味ないわ")
    responder.dialogue("なんかテレ東で卓球やってる").should == "興味ないわ"
    responder.last_hash.should == {0 => 1, 2 => 3}
    responder.last_sorted_hash.should == [[2, 3], [0, 1]]
  end
end
