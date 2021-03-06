# -*- coding: utf-8 -*-

require_relative "base"
require_relative "../morpheme"

module Albatro
  module Responder
    class SweetsResponder < Base
      def dialogue(input, options = {})
        keywords = Albatro::Morpheme.instance.pickup_keywords(input, :pickup => ["名詞"], :reject => ["形容動詞語幹", "代名詞", "非自立"])
        if keyword = keywords.sample
          [
            "%s男子(笑)",
            "プチ%s(笑)",
            "%sをプロデュース(笑)",
            "思い切って%s(笑)",
            "%sで血液サラサラ(笑)",
          ].sample % keyword
        end
      end
    end
  end
end

if $0 == __FILE__
  Albatro::Responder::SweetsResponder.new.interactive(:messages => ["ファミコン"])
end
