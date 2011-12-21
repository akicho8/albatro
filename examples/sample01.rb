require File.expand_path(File.join(File.dirname(__FILE__), "../lib/albatro"))

responder = Albatro::MarkovResponder.new(:sample_at => :first)
responder.study_from_string("アヒルと鴨のコインロッカー")
puts responder.dialogue("", :always_newtopic => true).to_s
