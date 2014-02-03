require 'eventmachine'
# require 'em-http'
require "em-synchrony"
require "em-synchrony/em-http"
require 'nokogiri'
require 'open-uri'
require 'optparse'
require 'shelob'
require 'shelob/version'
require 'thread_safe'
require 'celluloid'

##
# A class to handle the request Asynchronously
##
class Request
  include Celluloid

  def initialize url
    @url = url
  end

  def get_response opts, queue, visited, outputFile, errOutputFile, num_in_progress
    http = EM::HttpRequest.new(@url).aget opts
    # http = EM::HttpRequest.new(url).get $request_opts

    http.callback {
      enqueue( @url, "a", "href", queue )
      visited.push @url
      resp = "#{http.response_header.status} - #{http.response.length} bytes\t#{@url}\n"
      output( outputFile, resp )
      puts resp
      num_in_progress -= 1
      return resp
    }

    http.errback {
      visited.push @url
      resp = "#{http.response_header.status} - #{http.response.length} bytes\t#{@url}\n"
      output( errOutputFile, resp )
      puts resp
      num_in_progress -= 1
      return resp
    }
  end
end

#
#
# TODO MAKE INTO A MODULE THAT CAN INIT WITH COMMAND LINE ARGS!!!
#
#
def init hostname, options = {}
  $root_url = hostname
  $visited = []
  $bad_urls = []

  $outputFile = File.open("logs/checked - " + Time.now.getlocal("-05:00").to_s + ".out", "a+")
  $compOutputFile = File.open("logs/found - " + Time.now.getlocal("-05:00").to_s + ".out", "a+")
  $errOutputFile = File.open("logs/error.out", "a+")
 
  $request_opts = {
    :connect_timeout => 10,
    :inactivity_timeout => 10,
    :redirects => 10
  }

  # arrays to store the urls in as they are found
  queue = ThreadSafe::Array.new
  img_links = ThreadSafe::Array.new

  # track the number of deferrables
  num_in_progress = 0
  queue.push $root_url

  EM.synchrony do
  # EM.run do
    do_stuff( queue, num_in_progress )
    EM.stop
  end

  0
end

##
#
##
def do_stuff queue, num_in_progress
# def do_stuff queue, more_links = true

  if !queue.empty? || num_in_progress > 0
    if !queue.empty?

      #   while !queue.empty? || num_in_progress > 0 do
      # if queue.length > 0
        
      #   url = queue.pop
      #   http = EM::HttpRequest.new(url).get( $request_opts )

      #   num_in_progress += 1

      concurrency = 5

      results = ThreadSafe::Array.new
      results.push EM::Synchrony::Iterator.new(queue, concurrency).map do |link, iter|

        url = link
        queue.delete link

        # Create a celluloid instance to asynchronously check the link
        currRequest = Request.new( url )
        iter.return currRequest.async.get_response(
          $request_opts,
          queue,
          $visited,
          $outputFile,
          $errOutputFile,
          num_in_progress
        )
      end
    end

    # do_stuff( queue.uniq, queue.empty?)
    do_stuff( queue.uniq, num_in_progress)
  end

  puts "done!"
end

##
# add new found urls to the queue to be checked
##
def enqueue url, tag, attribute, queue
  begin
    Nokogiri::HTML( open(url) ).css( tag ).map do |link|
      href = link.attr( attribute )
      output( $compOutputFile, href )

      # be sure the url is one we can and intend to open
      if verify_link href

        # if the url doesn't have the correct domain, add it
        if !href.start_with? $root_url
          format_link href
        end

        # if we haven't seen it, add the url to the queue
        if queue.include?( href ) or $visited.include?( href )
          href = nil
        else
          queue.push href
        end
      end
    end
  rescue OpenURI::HTTPError
    output( $errOutputFile, "OpenURI::HttpError - " + url +", " + tag + ", " + attribute )
  end
  queue.compact.uniq
end

##
# ensures the link starts with the configured suffix
##
def verify_link href 
  return !href.nil? && (
      href.starts_with? 'americanexpress.com/us/small-business/openforum' ||
      href[0] == '/'
    )
end

##
# reformat the url to one that an Http request can be made
##
def format_link link
  puts "reformatting: " + link
  return URI::join( $root_url, link )
end

##
# Filter links to ensure they are children of the root
# url, and removes duplicates
##
def filter links
  links.select do |link|
    link.start_with? @hostname
  end.uniq
end

##
# output the given line to the file object
##
def output( file, line )
  file.syswrite( line.to_s + "\n" )
end

##
##
##   UNFINISHED SCRIPT...  NEEDS TRANSLATION TO OBJECT ORIENTED
##
##

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: link_checker.rb [options] root_url"

  opts.on('-s', '--seed SEED_URL', "Initial seed url if different from root url") do |seed|
    options[:seed] = seed
  end
  
  opts.on('-a', '--async NUM_OF_THREADS', "Forces tool to run asynchronously, limits the number of threads to the specified threshold") do |async|
    options[:async] = async
  end

  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    exit
  end
end.parse!

if ARGV.empty?
  puts optparse
  exit 1
end

begin
  exit init(ARGV[0], options)
# rescue => ex
#   STDERR.puts ex.message
end