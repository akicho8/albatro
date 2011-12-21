# -*- coding: utf-8 -*-
require "spec_helper"
require "albatro/recommend_responder"

describe Albatro::RecommendResponder do
  it "dialogue" do
    obj = Albatro::RecommendResponder.new
    obj.study_from_string("AAとCCとCC")
    obj.dictionary.should == {"CC"=>{"AA"=>1}, "AA"=>{"CC"=>1}}
    obj.study_from_string("BBとCC")
    obj.study_from_string("BBとDDとCC")
    obj.dialogue("AA", :count => 2).should == "AAを発言した人はCCも発言しています"
    obj.dialogue("CC", :count => 1).should == "CCを発言した人はBBも発言しています"
    obj.dialogue("EE").should be_blank
  end
end
