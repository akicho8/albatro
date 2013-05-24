# -*- coding: utf-8 -*-
source "https://rubygems.org"
gemspec

current_dir = File.expand_path(File.join(File.dirname(__FILE__), "."))

# ↓ これらを gemspec の中でかけないの？？？
gem "rain_table", :git => "https://github.com/akicho8/rain_table.git"
gem "tree_support", :git => "https://github.com/akicho8/tree_support.git"
# gem "mecab-ruby", :git => "git://github.com/cookpad/mecab-ruby-gem.git", :require => "MeCab"
gem "mecab-ruby", ">= 0.99", :path => "#{current_dir}/vendor/mecab-ruby-0.996", :require => "MeCab"
