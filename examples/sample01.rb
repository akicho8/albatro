# -*- coding: utf-8 -*-
require "bundler/setup"
Bundler.require

responder = Albatro::MarkovResponder.new(:sample_at => :first)
responder.study_from_string("アヒルと鴨のコインロッカー")
puts responder.dialogue("", :always_newtopic => true).to_s
