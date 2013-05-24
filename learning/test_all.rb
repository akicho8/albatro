require_relative 'helper'
Chat::VipRoom = Chat::SilentRoom
Dir[File.expand_path(File.join(File.dirname(__FILE__), "0*.rb"))].each{|filename|load(filename)}
