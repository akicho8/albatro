# -*- coding: utf-8 -*-
require "spec_helper"
require "albatro/twitter_responder"

describe Albatro::TwitterResponder do
  it "dialogue" do
    responder = Albatro::TwitterResponder.new(:mock => true)
    responder.dialogue("「初音ミク」の「痛車」").should be_present
  end
end
