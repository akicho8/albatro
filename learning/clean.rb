require "fileutils"
require "pathname"
FileUtils.rm(Pathname.glob(File.expand_path(File.join(File.dirname(__FILE__), "tmp/*"))), :verbose => true, :noop => false)
