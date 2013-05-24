# -*- coding: utf-8 -*-
require_relative "responder"
require_relative "morpheme"

class Albatro::LaughResponder < Albatro::Responder
  def dialogue(input, options = {})
    keywords = Albatro::Morpheme.instance.pickup_keywords(input, :pickup => ["名詞"], :reject => ["形容動詞語幹", "代名詞", "非自立"])
    if keyword = keywords.sample
      "#{keyword}(笑)"
    end
  end
end

if $0 == __FILE__
  Albatro::LaughResponder.new.interactive(:messages => ["ファミコン"])
end
