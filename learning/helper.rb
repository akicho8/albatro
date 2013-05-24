# -*- coding: utf-8 -*-
require_relative 'chat'

# 汎用ボット
class SBot < Chat::SimpleBot
end

# マルコフ用ボット
class MBot < Chat::SimpleBot
  def setup(*)
    super
    if @response.kind_of? Albatro::MarkovResponder
      raise ArgumentError, "#{self.class.name} は Albatro::MarkovResponder 専用です"
    end
  end

  def dialogue(input)
    options = @params[:dopt].call
    options[:name] = name
    if @params[:chain_max]
      options[:chain_max] = @params[:chain_max].to_a.sample
    end
    options[:always_newtopic] = @params[:always_newtopic]
    options[:rescue_silent] = @params[:rescue_silent]
    options[:nodes_sort_type] = @params[:nodes_sort_type] || :rand
    @responder.dialogue(input, options)
  end
end

@bots = {
  :hatsune_miku => MBot.new(:responder => Albatro::MarkovResponder.new(:prefix => 1), :chain_max => (4..16), :rescue_silent => true, :dicname => "hatsune_miku", :name => "初音ミク"),
  :famicom => MBot.new(:responder => Albatro::MarkovResponder.new(:prefix => 1), :chain_max => (8..16), :rescue_silent => true, :dicname => "famicom", :name => "任天堂"),
  :okarin => MBot.new(:responder => Albatro::MarkovResponder.new(:prefix => 1), :chain_max => (4..20), :rescue_silent => true, :dicname => "okarin", :name => "おかりん"),
  :masason => MBot.new(:responder => Albatro::MarkovResponder.new(:prefix => 1), :chain_max => (5..16), :rescue_silent => true, :dicname => "masason", :name => "孫正義"),
  :neraa => MBot.new(:responder => Albatro::MarkovResponder.new(:prefix => 1), :chain_max => (2..10), :rescue_silent => true, :dicname => "yoshinoya_2ch", :name => "ネラー"),
  :sweets_killer => MBot.new(:responder => Albatro::MarkovResponder.new(:prefix => 1), :chain_max => (4..10), :rescue_silent => true, :dicname => "sweets", :name => "スイーツキラー"),
  # :natsume => MBot.new(:responder => Albatro::MarkovResponder.new(:prefix => 2), :chain_max => (2..20), :rescue_silent => false, :dicname => "bocchan", :name => "夏目"),
  :arigachi => MBot.new(:responder => Albatro::MarkovResponder.new(:prefix => 1), :chain_max => (2..10), :rescue_silent => true, :dicname => "jpop_arigachi", :name => "ありがち"),
  :jimio => MBot.new(:responder => Albatro::MarkovResponder.new(:prefix => 2), :chain_max => (7..15), :rescue_silent => true, :dicname => "jimina", :name => "地味男"),
  :usagi => MBot.new(:responder => Albatro::MarkovResponder.new(:prefix => 2), :chain_max => (1..10), :rescue_silent => true, :dicname => "usagi", :name => "うさぎ"),
  :nicochu => MBot.new(:responder => Albatro::MarkovResponder.new(:prefix => 1), :chain_max => (5..16), :rescue_silent => true, :dicname => ["kami", "hyouka", "muda"], :name => "ニコ厨"),
  :eamoto => MBot.new(:responder => Albatro::MarkovResponder.new(:prefix => 1), :chain_max => (4..12), :rescue_silent => true, :dicname => ["eamoto"], :name => "エア本さん"),
  :shimo => MBot.new(:responder => Albatro::MarkovResponder.new(:prefix => 1), :chain_max => (2..16), :rescue_silent => true, :dicname => ["kumikyoku_nico"], :name => "ニコニコ組曲"),
  :evachu => MBot.new(:responder => Albatro::MarkovResponder.new(:prefix => 1), :chain_max => (8..32), :rescue_silent => true, :dicname => ["eva"], :name => "エヴァ厨"),
  :doraemon => MBot.new(:responder => Albatro::MarkovResponder.new(:prefix => 1), :chain_max => (4..12), :rescue_silent => true, :dicname => "doraemon", :name => "ドラえもん"),
  :mennaku => MBot.new(:responder => Albatro::MarkovResponder.new(:prefix => 1), :chain_max => (3..12), :rescue_silent => true, :dicname => "mennaku", :name => "聖夜"),

  # 空気を読まない
  :oneline_aa => SBot.new(:responder => Albatro::RandomResponder.new, :dicname => "oneline_aa", :format => :lines, :name => "こすりつけ"),

  # Amazon型(学習あり)
  :amazon => SBot.new(:responder => Albatro::Recommend2Responder.new, :dopt => proc{{:count => (1..2).to_a.sample}}, :may_study => true, :name => "あまぞん"),

  # ログ型(学習あり)
  :reudy => SBot.new(:responder => Albatro::LogResponder.new(:sort_type => :rand), :dopt => proc{{}}, :may_study => true, :name => "似非ロイディ"),

  :akasan => SBot.new(:responder => Albatro::AskResponder.new, :name => "赤さん"),
  :tsuda => SBot.new(:responder => Albatro::TwitterResponder.new, :name => "津田"),
  :kensaku => SBot.new(:responder => Albatro::NetResponder.new, :name => "ネットランナー"),
}

def net_responder_run(chat_klass, human)
  chat_klass.open{|room|
    room.join(SBot.new(:responder => human, :name => "おかりん"))
    room.join(SBot.new(:responder => Albatro::NetResponder.new, :name => "まゆしぃ"))
    room.main_loop
  }
end

if $0 == __FILE__
  Chat::SilentRoom.open(:name => "Aチャンネル") do |room|
    # room.join(SBot.new(:responder => Albatro::DebugResponder.new, :name => "Bot1"))
    # room.join(SBot.new(:responder => Albatro::HumanResponder.new, :name => "Bot2"))
    # room.join(SBot.new(:responder => Albatro::WhatResponder.new,  :name => "Bot3"))
    # room.join(SBot.new(:responder => Albatro::MarkovResponder.new(:prefix => 1), :dopt => proc{{:chain_max => (4..12).to_a.sample, :rescue_silent => true}}, :dicname => ["eamoto", "muda"], :name => "名前"))

    # room.join(@bots[:famicom])
    # room.join(@bots[:okarin])
    # room.join(@bots[:oneline_aa])
    # room.join(@bots[:masason])
    # room.join(@bots[:neraa])
    # room.join(@bots[:sweets_killer])
    # room.join(@bots[:arigachi])
    # room.join(@bots[:jimio])
    # room.join(@bots[:usagi])
    # room.join(@bots[:nicochu])
    # room.join(@bots[:eamoto])
    # room.join(@bots[:shimo])
    # room.join(@bots[:evachu])
    room.join(@bots[:hatsune_miku])
    # room.join(@bots[:doraemon])
    # room.join(@bots[:mennaku])
    # room.join(@bots[:amazon])
    # room.join(@bots[:akasan])
    # room.join(@bots[:tsuda])
    # room.join(@bots[:kensaku])

    # room.main_loop(:max => 100)
    room.main_loop(:max => 2000){room.alone}
  end
end
