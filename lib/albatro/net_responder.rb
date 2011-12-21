# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "responder"))
require File.expand_path(File.join(File.dirname(__FILE__), "morpheme"))

require "google-search"
require "sanitize"
require "active_support/core_ext/object/to_query"
require "active_support/core_ext/hash/conversions"

require "socket"
require "open-uri"
require "pathname"

module Albatro
  #
  # Google WEB 検索
  #
  #   p dialogue("初音ミクとは？") #=>
  #
  module GoogleWebDialgue
    def dialogue(input, options = {})
      response = super and return response
      if md = input.to_s.match(/(.+)とは/)
        name = md.captures.first
        query = "#{name}とは"
        if @options[:mock]
          response = "<b>石原 慎太郎</b>（いしはら しんたろう、旧字体:石原 愼太郎、1932年（昭和7年）9月30日 -   ）は、日本の政治家、作家。東京都知事（第14・15・16・17代）。 <b>...</b>"
        else
          search = Google::Search::Web.new(:query => query)
          if item = search.all_items.first
            response = item.content
          end
        end
        if response
          response = Sanitize.clean(response)
          response = response.gsub(/[\s。.]+$/, "")
          response = response + "だそうです"
        end
        Albatro.logger.debug("#{input} #=> #{response}") if Albatro.logger
        response
      end
    end
  end

  #
  # Google 画像 検索
  #
  #   p dialogue("初音ミクの画像ください") #=> "http://image.space.rakuten.co.jp/lg01/57/0000914157/89/img2ae7e70czik5zj.jpeg"
  #
  module GoogleImageDialgue
    def dialogue(input, options = {})
      response = super and return response
      if md = input.to_s.match(/(.+)の画像/)
        if @options[:mock]
          response = "http://image01.wiki.livedoor.jp/m/a/mounena/9e135b6543686eaa.jpg"
        else
          query = md.captures.first
          search = Google::Search::Image.new(:query => query, :image_size => :xlarge)
          if item = search.all_items.first
            response = item.uri
          end
        end
      end
    end
  end

  #
  # Amazon 商品 検索
  #
  #   p dialogue("初音ミクが欲しい") #=> "初音ミク-Project DIVA-のこと？"
  #   p dialogue("...")              #=> "http://miku.sega.jp/"
  #
  #   発言をキューにいれて2連続で発言するのが特徴
  #
  module AmazonDialgue
    def dialogue(input, options = {})
      response = super and return response
      if md = input.to_s.match(/(.+)が欲しい/)
        if @options[:mock]
          response = "ゴールデンスランバー (新潮文庫)"
        else
          require "amazon/ecs"
          Amazon::Ecs.options = {
            :aWS_access_key_id => ENV["AWS_ACCESS_KEY_ID"],
            :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"],
            :country           => :jp,
          }
          res = Amazon::Ecs.item_search(md.captures.first, {:response_group => "Medium", :sort => "salesrank"})
          if item = res.items.first
            response = item.get("itemattributes/title")
          end
        end
        if response
          response + " のこと？"
        end
      end
    end
  end

  #
  # 天気に詳しい
  #
  #   p dialogue("明日の天気大丈夫かなあ") #=> "雨らしいよ"
  #
  #   curl http://weather.livedoor.com/forecast/rss/forecastmap.xml
  #
  module WeatherDialgue
    def dialogue(input, options = {})
      response = super and return response
      if md = input.to_s.match(/天気/)
        day = "today"
        if input.to_s.match(/明日/)
          day = "tomorrow"
        end
        query = {
          :city => 63, # 東京
          :day  => day,
        }
        if @options[:mock]
          attrs = eval(Pathname(File.join(File.dirname(__FILE__), "../../fixtures/weather_response.rb")).read)
        else
          attrs = Hash.from_xml(open("http://weather.livedoor.com/forecast/webservice/rest/v1?#{query.to_query}").read)
        end
        response = attrs["lwws"]["telop"].gsub(/時々/, "ときどき") + "らしいよ"
      end
      response
    end
  end

  class NetResponder < Responder
    include GoogleWebDialgue
    include GoogleImageDialgue
    include AmazonDialgue
    include WeatherDialgue

    #
    # input 対する応答
    #
    def dialogue(input, options = {})
      super
    rescue SocketError
    end
  end
end

if $0 == __FILE__
  messages = [
    "初音ミクの画像ください",
    "伊坂幸太郎の本が欲しい",
    "自炊の本が欲しい",
    "卓球台が欲しい",
    "石原慎太郎とは誰ですか",
    "初音ミクとは何ですか",
    "明日の天気大丈夫かなあ",
  ]
  Albatro::NetResponder.new(:mock => true).interactive(:messages => messages)
end

# [?] 初音ミクの画像ください
# [NetResponder] http://a0.twimg.com/profile_images/1278882154/popopopon_normal.jpg
# [?] 伊坂幸太郎の本が欲しい
# [NetResponder] ゴールデンスランバー (新潮文庫)のこと？
# [?] 自炊の本が欲しい
# [NetResponder] つくりおきおかずで朝つめるだけ!弁当 決定版 (別冊エッセ)のこと？
# [?] 卓球台が欲しい
# [NetResponder] 卓球台—冨田正吉句集 (朝俳句叢書)のこと？
# [?] 石原慎太郎とは誰ですか
# [NetResponder] 石原 慎太郎（いしはら しんたろう、旧字体:石原 愼太郎、1932年（昭和7年）9月30日 - ）は、日本の政治家、作家。東京都知事（第14・15・16・17代）だそうです
# [?] 初音ミクとは何ですか
# [NetResponder] 初音 ミク（はつね ミク、HATSUNE MIKU）は、クリプトン・フューチャー・メディアから 発売されている音声合成・デスクトップミュージック（DTM）ソフトウェアの製品だそうです
