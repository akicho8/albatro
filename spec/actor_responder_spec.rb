require "spec_helper"
require "albatro/actor_responder"

describe Albatro::ActorResponder do
  it "dialogue" do
    responder = Albatro::ActorResponder.new(:messages => ["1", "2"])
    responder.dialogue("").should == "1"
    responder.dialogue("").should == "2"
    responder.dialogue("").should == nil
  end
end
