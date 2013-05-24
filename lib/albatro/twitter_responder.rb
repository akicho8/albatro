# -*- coding: utf-8 -*-

require "active_support/core_ext/string"

require_relative "responder"
require_relative "morpheme"

module Albatro
  #
  # 入力文からキーワードを2つ拾ってTwitter検索してhttpが入ってないメッセージを表示
  #
  #   responder = Albatro::TwitterResponder.new
  #   p responder.dialogue("「初音ミク」の「痛車」") #=> "ロシアのNo.1のドライバーの車って初音ミクさんなのか"
  #
  class TwitterResponder < Responder
    def dialogue(input, options = {})
      keywords = Albatro::Morpheme.instance.pickup_keywords(input)
      keywords = keywords.shuffle.first(2)
      query = keywords.join(" ")
      if query.present?
        resp = tweet_resp(query)
        records = resp["results"].collect{|record|record["text"]}
        records = records.collect{|line|line.gsub(/^@\w+/, "")}     # "@user OK" #=> "OK"
        records = records.collect{|line|line.gsub(/RT\s+.*/, "")}   # "wwwRT ..." #=> "www"
        records = records.collect{|line|line.gsub(/#[a-z_]+/, "")}  # "#foo" #=> ""
        records = records.reject{|line|line.match(/http/)}          # http が含まれるものを削除
        if text = records.sample
          text = text.squish
          if text.scan(/./).size >= 100
            # 文が長すぎるので切る
            sentences = Albatro::Morpheme.instance.text_to_sentences(text)
            text = sentences.first
          end
          text.presence
        end
      end
    end

    #
    # input を twitter 検索
    #
    def tweet_resp(query)
      if @options[:mock]
        return {"max_id"=>59964822242082816, "results"=>[{"created_at"=>"Mon, 18 Apr 2011 12:36:52 +0000", "profile_image_url"=>"http://a3.twimg.com/profile_images/667374054/________normal.JPG", "from_user_id_str"=>"93901985", "id_str"=>"59958574629126144", "from_user"=>"kurotama2", "text"=>"ロシアのNo.1のドライバーの車って初音ミクさんのおパンチュ号なのか\n公式レースにも痛車参加してるってすごいな", "to_user_id"=>nil, "metadata"=>{"result_type"=>"recent"}, "id"=>59958574629126144, "geo"=>nil, "from_user_id"=>93901985, "iso_language_code"=>"ja", "source"=>"&lt;a href=&quot;http://stone.com/Twittelator&quot; rel=&quot;nofollow&quot;&gt;Twittelator&lt;/a&gt;", "to_user_id_str"=>nil}, {"created_at"=>"Mon, 18 Apr 2011 12:03:17 +0000", "profile_image_url"=>"http://a2.twimg.com/profile_images/1098312891/______normal.jpg", "from_user_id_str"=>"139039050", "id_str"=>"59950120250257408", "from_user"=>"europa_blog", "text"=>"【ブログ記事】　ロシア1位のドリフトレーサーは『初音ミク』の痛車に乗っている http://fc2.in/hY2S6z", "to_user_id"=>nil, "metadata"=>{"result_type"=>"recent"}, "id"=>59950120250257408, "geo"=>nil, "from_user_id"=>139039050, "iso_language_code"=>"ja", "source"=>"&lt;a href=&quot;http://blog.fc2.com/&quot; rel=&quot;nofollow&quot;&gt;FC2 Blog Notify&lt;/a&gt;", "to_user_id_str"=>nil}], "since_id"=>0, "refresh_url"=>"?since_id=59964822242082816&q=%E5%88%9D%E9%9F%B3%E3%83%9F%E3%82%AF+%E7%97%9B%E8%BB%8A", "next_page"=>"?page=2&max_id=59964822242082816&rpp=10&q=%E5%88%9D%E9%9F%B3%E3%83%9F%E3%82%AF+%E7%97%9B%E8%BB%8A", "page"=>1, "results_per_page"=>10, "completed_in"=>0.017773, "since_id_str"=>"0", "query"=>"%E5%88%9D%E9%9F%B3%E3%83%9F%E3%82%AF+%E7%97%9B%E8%BB%8A", "max_id_str"=>"59964822242082816"}
      end
      begin
        TwitterOAuth::Client.new.search(query, :rpp => 50)
      rescue
        {"results" => [{"text" => "ネットに繋げてくれ！"}]}
      end
    end
  end
end

if $0 == __FILE__
  Albatro::TwitterResponder.new(:mock => true).interactive(:messages => ["「初音ミク」の「痛車」", "焼肉ラーメンってあるの？"])
end
