#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'scraperwiki'
require 'scraped'
require 'pry'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

@parties = {
  'AKA' => 'Aelon Kein Ad',
  'KEA' => 'Kien Eo Am',
  'UPP' => "United People's Party",
  'UDP' => 'United Democratic Party',
  'IND' => 'Independent',
}

def party_info(text)
  if text =~ /(.*?)\s+\((.*?)\)/
    [Regexp.last_match(1), Regexp.last_match(2), @parties[Regexp.last_match(2)]]
  else
    raise "No party in #{text}"
  end
end

def scrape_wikipedia(url)
  noko = noko_for(url)
  noko.xpath('.//h2[contains(.,"Members")]/following-sibling::ul[1]/li').flat_map do |line|
    area, who = line.text.split(' - ')
    members = who.split(/,\s*/)
    members.map do |m|
      name, party_id, party = party_info(m)
      {
        name:         name.sub(/^'/, '').sub(/'$/, ''),
        party_id:     party_id,
        party:        party,
        constituency: area,
      }
    end
  end
end

data = scrape_wikipedia('https://en.wikipedia.org/w/index.php?title=Legislature_of_the_Marshall_Islands&oldid=672387367')
# puts data
ScraperWiki.save_sqlite(%i(name), data)
