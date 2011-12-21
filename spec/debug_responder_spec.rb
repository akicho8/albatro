require "spec_helper"
require "albatro/debug_responder"

describe Albatro::DebugResponder do
  it "dialogue" do
    responder = Albatro::DebugResponder.new
    responder.dialogue("input").should be_present
  end
end
