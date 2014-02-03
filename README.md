linkchecker
===========

Written in Ruby, takes in configuration options to crawl a given URL and asynchronously hits each URL found on the page.
Mainly used for double checking that your site has not exposed broken links.

# Features:
    
    ## Currently
    
    Http/Https
    Asynchronous
    Individual output files for:  Errors, Checked links, All links
    
    ## Future
    
    Oauth
    Define html tags to search the page for
    Specify threshold for number of concurrent threads
    

# LinkChecker

Starts on a given page, finds all links on the page, ensure they resolve, and recurses if the link is underneath the starting url. Intended primarily for double checking that your site has no horrible error pages to be exposed to the user by clicking on a link. 

## Current Usage

    ruby linkchecker.rb root_url

## Requirements

    LinkChecker requires Ruby 1.9.3 or newer

## Installation

    clone this repository
    navigate into the top directory
    
execute:

    $ bundle
    $ ruby linkchecker.rb <root_url>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Make sure you have tests, and they pass! (`rake`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
