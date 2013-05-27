# -*- coding: utf-8 -*-
require "spec_helper"
require "albatro/responder/twitter_responder"

describe Responder::TwitterResponder do
  it "dialogue" do
    responder = Responder::TwitterResponder.new(:mock => true)
    responder.dialogue("「初音ミク」の「痛車」").should be_present
  end
end
