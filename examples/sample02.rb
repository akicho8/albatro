# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "../lib/albatro"))

Albatro::Morpheme.instance.analyze_display("アヒルと鴨のコインロッカー")

Albatro::Morpheme.instance.analyze_display("で、よく見たら")
Albatro::Morpheme.instance.analyze_display("昨日で、失敗")
Albatro::Morpheme.instance.analyze_display("それが、失敗")
Albatro::Morpheme.instance.analyze_display("昨日は、よく寝た")
