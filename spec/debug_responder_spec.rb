require "spec_helper"
require "albatro/responder/debug_responder"

describe Responder::DebugResponder do
  it "dialogue" do
    responder = Responder::DebugResponder.new
    responder.dialogue("input").should be_present
  end
end
