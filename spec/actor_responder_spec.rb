require "spec_helper"
require "albatro/responder/actor_responder"

describe Responder::ActorResponder do
  it "dialogue" do
    responder = Responder::ActorResponder.new(:messages => ["1", "2"])
    responder.dialogue("").should == "1"
    responder.dialogue("").should == "2"
    responder.dialogue("").should == nil
  end
end
