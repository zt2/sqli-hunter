#!/usr/bin/env ruby
$LOAD_PATH << File.dirname(File.realpath(__FILE__))
require 'lib/environment'

ARGV << '-h' if ARGV.empty?
helper = Hunter::Helper.new
helper.start
