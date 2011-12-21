# -*- coding: utf-8 -*-
require "sdl"
require "singleton"
require "pathname"

#
# WAVファイル再生管理
#
class SoundUtils
  include Singleton

  def initialize
    require "sdl"
    SDL::init(SDL::INIT_AUDIO)
    SDL::Mixer.open(44100)
    SDL::Mixer.set_volume_music(128) # ボリューム(max:128)
    @sound_directory = Pathname(File.expand_path(File.join(File.dirname(__FILE__), "assets")))
    @music_cache = {}
  end

  #
  # 指定の効果音を再生
  #
  #   sound_se("A1_17276")                # 再生が終わるまで待たない
  #   sound_se("A1_17276", :sync => true) # 再生が終わるまで待つ
  #
  def sound_se(name, options = {})
    options = {
      :sync => false,
    }.merge(options)
    if music = music_get(name)
      SDL::Mixer.play_music(music, 0)
      if options[:sync]
        sound_wait
      end
    end
  end

  #
  # 効果音が止まるまで待つ
  #
  def sound_wait
    while SDL::Mixer::play_music?
      sleep(0.1)
    end
  end

  private

  #
  # 指定のデータを取得
  #
  def music_get(name)
    unless @music_cache[name]
      filename = @sound_directory + "#{name}.WAV"
      if filename.exist?
        # puts "load: #{filename}"
        @music_cache[name] = SDL::Mixer::Music.load(filename.to_s)
      end
    end
    @music_cache[name]
  end
end

if $0 == __FILE__
  # SoundUtils.instance.sound_se("A1_17276", :sync => true)
  SoundUtils.instance.sound_se("Message Received", :sync => true)
  SoundUtils.instance.sound_se("Message Sent", :sync => true)
end
