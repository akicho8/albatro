#/usr/local/bin/ruby -Ku
require File.expand_path(File.join(File.dirname(__FILE__), "helper"))
Albatro::Morpheme.instance.analyze_display("犯人はヤス")
