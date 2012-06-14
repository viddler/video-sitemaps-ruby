DIY Video Sitemaps using The Viddler API (Ruby)
===============================================

A simple way to create your own video sitemap files for your site.
A PHP version of this (without a cli) exists at https://github.com/viddler/Video-Sitemaps

Install
-------
    $ gem install viddler-sitemaps

Run from CLI
------------
    $ viddler-sitemaps -k myapikey -u myviddlerusername -p myvidlerpass /folder/to/save/xml/files
      #=> Indexed 105 videos to /folder/to/save/xml/files

Run from your ruby code
-----------------------
    require 'rubygems'
    require 'viddler-sitemaps'

    sitemap = Viddler::Sitemap.new(api_key, username, password)
    indexed_videos = sitemap.generate!(folder)
    puts "Indexed #{indexed_videos} videos to #{folder}"

Code Docs
---------
http://rubydoc.info/github/viddler/video-sitemaps-ruby/master/frames
