# -*- coding: utf-8 -*-
require_relative "responder"

module Albatro
  class WhatResponder < Responder
    def dialogue(input, options = {})
      if input.present?
        "#{input}ってなに？"
      end
    end
  end
end

if $0 == __FILE__
  Albatro::WhatResponder.new.interactive
end
