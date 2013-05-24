require_relative 'sound_utils'

module Chat
  class SoundObserver
    def update(command, *args)
      case command
      when :say
        SoundUtils.instance.sound_se("Message Received", :sync => true)
      end
    end
  end
end

if $0 == __FILE__
  object = Chat::SoundObserver.new
  object.update(:say, "OK")
end
