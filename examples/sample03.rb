# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "../lib/albatro"))

responder = Albatro::MarkovResponder.new
responder.study_from_string("アヒルと鴨のコインロッカー")
responder.to_dot(:file => "#{File.basename(__FILE__, '.*')}.png", :root_display => true)
