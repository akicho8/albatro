require "spec_helper"
require "albatro/responder/random_responder"

describe Responder::RandomResponder do
  it "dialogue" do
    responder = Responder::RandomResponder.new
    messages = ("a" .. "z").to_a
    messages.each{|message|responder.study_from_string(message)}
    responder.dialogue("").should be_present
  end
end

