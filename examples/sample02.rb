# -*- coding: utf-8 -*-
require "bundler/setup"
Bundler.require

Albatro::Morpheme.instance.analyze_display("アヒルと鴨のコインロッカー")

Albatro::Morpheme.instance.analyze_display("で、よく見たら")
Albatro::Morpheme.instance.analyze_display("昨日で、失敗")
Albatro::Morpheme.instance.analyze_display("それが、失敗")
Albatro::Morpheme.instance.analyze_display("昨日は、よく寝た")
