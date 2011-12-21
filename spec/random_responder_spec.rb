require "spec_helper"
require "albatro/random_responder"

describe Albatro::RandomResponder do
  it "dialogue" do
    responder = Albatro::RandomResponder.new
    messages = ("a" .. "z").to_a
    messages.each{|message|responder.study_from_string(message)}
    responder.dialogue("").should be_present
  end
end

