#!/usr/bin/env ruby
# encoding: utf-8

require "eventmachine"
require "amqp"

EventMachine.run do
  connection = AMQP.connect(:host => '198.61.214.103')
  puts "Connected to AMQP broker. Running #{AMQP::VERSION} version of the gem..."

  channel  = AMQP::Channel.new(connection)
  queue    = channel.queue("amqpgem.examples.helloworld", :auto_delete => true)
  exchange = channel.direct("")

  queue.subscribe do |payload|
    puts "Received a message: #{payload}. Disconnecting..."
    connection.close { EventMachine.stop }
  end

  exchange.publish "Hello, world!", :routing_key => queue.name
end