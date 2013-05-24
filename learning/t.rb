#!/usr/local/bin/ruby -Ku
# -*- coding: utf-8 -*-

require "kconv"
require "drb/drb"
require "timeout"
require "net/ping"
require "resolv"

module Chat
  class TalkClient
    def initialize(params = {})
      @params = {
        :host => "192.168.11.50", # ホスト
        :port => 50100,           # ポート
      }.merge(params)

      host_with_port = [@params[:host], @params[:port]].join(":")
      if Net::Ping::External.new(@params[:host], @params[:port], 1).ping?
        @object = DRb::DRbObject.new_with_uri("druby://#{host_with_port}")
      else
        puts "#{host_with_port} に接続できません"
      end
      @error_count = 0
    end

    def talk(str, options = {})
      options = {
        :program_no => 1,    # 音質(1-8)
        :tone       => 100,  # 音程(50-200)
        :volume     => 100,  # 音量(1-100)
        :speed      => -1,   # 速度(50-300)
      }.merge(options)
      if options[:force]
        stop
      end
      if str.to_s.strip.empty?
        return
      end
      safe_block(3) do
        @object.talk(str.to_s, [options[:speed], options[:tone], options[:volume], options[:program_no]].join(" "))
      end
      if options[:sync]
        wait_loop(str, options)
      end
    end

    def wait_loop(str, options)
      safe_block(30) do
        sleep(str.scan(/./).size * 0.1)
        while @error_count == 0
          resp = remote_talk("/GetNowPlaying")
          if resp.include?("受信：NowPlayingは有効です(音声再生中)")
            sleep(0.25)
          else
            break
          end
        end
      end
    end

    def stop
      remote_talk("/Clear") # 次の行以降をクリア
      remote_talk("/Skip")  # 現在の行をスキップ
    end

    def remote_talk(*args)
      safe_block(3) do
        @object.remote_talk(*args).to_s.toutf8
      end
    end

    private

    def safe_block(timeup)
      if @error_count == 0 && @object
        begin
          timeout(timeup) do
            yield
          end
        rescue Timeout::Error, DRb::DRbConnError => error
          @error_count += 1
          p error
        end
      end
    end
  end
end

if $0 == __FILE__
  object = Chat::TalkClient.new
  str = ARGV.to_s
  object.talk(str, :tone => 100, :program_no => 1, :speed => 80, :volume => 100) # ゆっくり
  # object.talk(str, :tone => 100, :program_no => 9, :speed => 120, :volume => 100) # はつね
end
