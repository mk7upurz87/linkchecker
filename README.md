LinkChecker
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
    
## Current Usage

    ruby linkchecker.rb root_url

## Requirements

    Ruby 1.9.3 or newer

## Installation

    clone this repository
    then navigate into the top directory
    
execute:

    $ bundle
    $ ruby linkchecker.rb <root_url>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am '<insert message about commit>'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
