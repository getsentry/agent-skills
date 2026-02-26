#!/usr/bin/env ruby
# frozen_string_literal: true
#
# tools/sentry_mock.rb — Local Sentry-compatible envelope receiver.
#
# Usage:
#   ruby tools/sentry_mock.rb [--port PORT] [--output FILE] [--timeout SECS]
#
# Defaults: port=9001, no output file, no timeout
#
# Fake DSN to use in apps:
#   http://test_key@localhost:9001/1

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "webrick"
end

require "webrick"
require "json"
require "zlib"
require "stringio"
require "optparse"

options = { port: 9001, output: nil, timeout: nil }
OptionParser.new do |opts|
  opts.on("--port PORT",    Integer) { |v| options[:port]    = v }
  opts.on("--output FILE")           { |v| options[:output]  = v }
  opts.on("--timeout SECS", Integer) { |v| options[:timeout] = v }
end.parse!

captured = []
mutex    = Mutex.new

def parse_envelope(body)
  lines = body.split("\n").reject(&:empty?)
  return nil if lines.empty?

  header   = JSON.parse(lines[0]) rescue {}
  event_id = header["event_id"]

  items = []
  i = 1
  while i < lines.length
    item_header = JSON.parse(lines[i]) rescue nil
    break unless item_header
    item_payload = JSON.parse(lines[i + 1]) rescue nil
    items << { type: item_header["type"], payload: item_payload }
    i += 2
  end

  { event_id: event_id, items: items, types: items.map { |it| it[:type] }.compact }
rescue => e
  warn "[mock] parse error: #{e.message}"
  nil
end

def write_output(path, captured)
  return unless path
  File.write(path, JSON.generate(
    captured.map { |e| { event_id: e[:event_id], types: e[:types] } }
  ))
end

server = WEBrick::HTTPServer.new(
  Port:      options[:port],
  Logger:    WEBrick::Log.new(IO::NULL),
  AccessLog: []
)

server.mount_proc("/") do |req, res|
  unless req.request_method == "POST" && req.path =~ %r{/api/\d+/envelope/}
    res.status = 404
    next
  end

  body = req.body.to_s
  if req["Content-Encoding"] == "gzip"
    body = Zlib::GzipReader.new(StringIO.new(body)).read rescue body
  end

  envelope = parse_envelope(body)
  if envelope
    mutex.synchronize { captured << envelope }
    printf "[mock] %s  id=%-8s  %s\n",
      Time.now.strftime("%H:%M:%S.%3N"),
      envelope[:event_id].to_s[0, 8],
      envelope[:types].join(", ")
    $stdout.flush
    write_output(options[:output], captured)
  end

  res.status            = 200
  res["Content-Type"]   = "application/json"
  res.body              = %Q({"id":"#{envelope&.dig(:event_id)}"})
end

if options[:timeout]
  Thread.new { sleep options[:timeout]; server.shutdown }
end

trap("INT") do
  write_output(options[:output], captured)
  puts "\n[mock] stopped — #{captured.length} envelope(s) captured"
  server.shutdown
end

at_exit { write_output(options[:output], captured) }

puts "[mock] Listening on port #{options[:port]}"
puts "[mock] Fake DSN: http://test_key@localhost:#{options[:port]}/1"
puts "[mock] Ctrl+C to stop"
server.start
