#!/usr/bin/env ruby
$LOAD_PATH << __dir__
require 'lib/environment'

ARGV << '-h' if ARGV.empty?
helper = Hunter::Helper.new
helper.start