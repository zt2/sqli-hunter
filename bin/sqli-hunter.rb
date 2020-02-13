#!/usr/bin/env ruby
# frozen_string_literal: true

#
# Standard libraries
#
require 'optparse'
require 'ostruct'

#
# Third party libraries
#
require_relative '../lib/hunter'

common_options = OpenStruct.new(
  host: 'localhost',
  port: 8080,
  sqlmap_host: 'localhost',
  sqlmap_port: 8775,
  targeted_hosts: []
)
sqlmap_options = OpenStruct.new(
  technique: 'BEUSTQ',
  threads: 5
)

puts "

  _____ _____ __    _     _____         _
  |   __|     |  |  |_|___|  |  |_ _ ___| |_ ___ ___
  |__   |  |  |  |__| |___|     | | |   |  _| -_|  _|
  |_____|__  _|_____|_|   |__|__|___|_|_|_| |___|_|
  |__|

      SQLMAP API wrapper by ztz (github.com/zt2)
      Version: #{Hunter::VERSION}

"

OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options]"
  opts.separator ''

  opts.separator 'Common options:'

  opts.on('-h', '--host=[HOST]', 'Bind host for proxy server (default is localhost)') do |host|
    common_options.host = host
  end

  opts.on('-p', '--port=[PORT]', OptionParser::DecimalInteger, 'Bind port for proxy server (default is 8080)') do |port|
    common_options.port = port
  end

  opts.on('--sqlmap-host=[HOST]', 'Host for sqlmap api (default is localhost)') do |host|
    common_options.sqlmap_host = host
  end

  opts.on('--sqlmap-port=[PORT]', OptionParser::DecimalInteger, 'Port for sqlmap api (default is 8775)') do |port|
    common_options.sqlmap_port = port
  end

  opts.on('--targeted-hosts=[HOSTS]', 'Targeted hosts split by comma (default is all)') do |hosts|
    common_options.targeted_hosts = hosts.split(',').map(&:strip)
  end

  opts.on('--version', 'Display version') do
    Hunter::Logger.info "SQLi-Hunter version: '#{Hunter::VERSION}'"
    exit
  end

  opts.separator ''
  opts.separator 'SQLMAP options'

  opts.on('--technique=[TECH]', 'SQL injection techniques to use (default "BEUSTQ")') do |tech|
    sqlmap_options.tech = tech
  end

  opts.on('--threads=[THREADS]', OptionParser::DecimalInteger, 'Max number of concurrent HTTP(s) requests (default 5)') do |threads|
    sqlmap_options.threads = threads
  end

  opts.on('--dbms=[DBMS]', 'Force back-end DBMS to this value') do |dbms|
    sqlmap_options.dbms = dbms
  end

  opts.on('--os=[OS]', 'Force back-end DBMS operating system to this value') do |os|
    sqlmap_options.os = os
  end

  opts.on('--tamper=[TAMPER]', 'Use given script(s) for tampering injection data') do |tamper|
    sqlmap_options.tamper = tamper
  end

  opts.on('--level=[LEVEL]', OptionParser::DecimalInteger, 'Level of tests to perform (1-5, default 1)') do |level|
    sqlmap_options.level = level
  end

  opts.on('--risk=[RISK]', OptionParser::DecimalInteger, 'Risk of tests to perform (0-3, default 1)') do |risk|
    sqlmap_options.risk = risk
  end

  opts.on('--mobile', 'Imitate smartphone through HTTP User-Agent header') do |mobile|
    sqlmap_options.mobile = mobile
  end

  opts.on('--smart', 'Conduct through tests only if positive heuristic(s)') do
    sqlmap_options.smart = true
  end

  opts.on('--random-agent', 'Use randomly selected HTTP User-Agent header value') do
    sqlmap_options.randomAgent = true
  end
end.parse!

Hunter::SQLMAP.config do |config|
  config.api_host = common_options.sqlmap_host
  config.api_port = common_options.sqlmap_port
  config.options = sqlmap_options.to_h
end

opts = {
  bind_host: common_options.host,
  bind_port: common_options.port,
  ca_crt_path: '../cert/sqli-hunter.pem',
  ca_key_path: '../cert/sqli-hunter.key',
  targets: common_options.targeted_hosts
}

proxy = Hunter::Proxy.new(opts)

trap(:TERM) do
  proxy.shutdown
  exit
end

trap(:INT) do
  proxy.shutdown
  exit
end

thread = proxy.start
thread.join
