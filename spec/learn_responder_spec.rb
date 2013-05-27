# -*- coding: utf-8 -*-
require "spec_helper"
require "albatro/responder/learn_responder"

describe Responder::LearnResponder do
  it "話の流れを記憶しておきそれをまねる" do
    responder = Responder::LearnResponder.new
    responder.study_from_string("a")
    responder.study_from_string("b")
    responder.dialogue("a").should == "b"
  end
end

