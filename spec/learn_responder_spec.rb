require "spec_helper"
require "albatro/learn_responder"

describe Albatro::LearnResponder do
  it "話の流れを記憶しておきそれをまねる" do
    responder = Albatro::LearnResponder.new
    responder.study_from_string("a")
    responder.study_from_string("b")
    responder.dialogue("a").should == "b"
  end
end

