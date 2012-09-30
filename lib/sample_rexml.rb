require 'net/http'
require 'rexml/document'
require 'action_view'
include REXML
include ActionView::Helpers::SanitizeHelper

feed = URI('http://threadbender.com/rss.xml')
feed = Document.new(Net::HTTP.get(feed))

#root = feed.root
#root.each_element('//item') { |item|
#  desc = item.delete_element('description').to_s
#  desc = strip_tags(desc)
#  date = item.delete_element('pubDate').to_s
#  date = strip_tags(date)
#  puts desc
#  puts date
#}

a, b = "UWDC W FXWYFC! WII IREC RA W FXWYFC. UXC QWY LXB MBCA EVZUXCAU RA MCYCZWIIH UXC BYC LXB RA LRIIRYM UB TB WYT TWZC. - TWIC FWZYCMRC".split(". - ")
puts a
puts b