# -*- coding: utf-8 -*-
require "bundler/setup"
Bundler.require

responder = Albatro::MarkovResponder.new
responder.study_from_string("アヒルと鴨のコインロッカー")
responder.to_dot(:file => "#{File.basename(__FILE__, '.*')}.png", :root_display => true)
