#!/usr/bin/env ruby
require 'json'
require 'net/https'
require 'nokogiri'
require 'set'

API_KEY = ENV['CANVAS_API_KEY']
unless API_KEY
  puts "Please set environment variable CANVAS_API_KEY with your key."
  exit(1)
end
COURSE_ID = ENV['COURSE_ID']
unless COURSE_ID
  puts "Please set environment variable COURSE_ID with the course id."
  exit(1)
end

SECTIONS = {
  843719 => 'benjamin.xls',
  843718 => 'patrick.xls',
  843717 => 'sen.xls',
  843716 => 'akshay.xls',
  843714 => 'colin.xls',
  843713 => 'nick.xls',
  843712 => 'fenil.xls',
  843711 => 'katy.xls',
  843710 => 'larry.xls',
  843709 => 'lara.xls',
  843708 => 'prasant.xls',
  843707 => 'sarah.xls',
  843706 => 'jackson.xls',
  843705 => 'michelle.xls',
  843270 => 'john.xls',
  843269 => 'jacob.xls',
}

u = URI('https://canvas.instructure.com/api/v1/courses/' + COURSE_ID + '/sections?include[]=students')
puts "getting sections for course #{COURSE_ID} at #{u}"
req = Net::HTTP::Get.new(u.request_uri)
req['Authorization'] = "Bearer #{API_KEY}"

res = Net::HTTP.start(u.hostname, u.port, use_ssl: true) do |http|
  http.request(req)
end
sections = JSON.parse(res.body)
lists = sections.map do |s|
  puts "Found #{s["students"].length} students in section #{s["id"]}"

  file = 'rosters/' + (SECTIONS[s["id"]] || '')
  unless File.file?(file)
    puts "No file found for section id #{s["id"]}"
    next
  end
  puts "Parsing file #{file}..."

  doc = Nokogiri::HTML(open(file))
  should_be_students = doc.xpath("//table/tr").map do |tr|
    student = tr.xpath("td[5]").first
    next unless (student && student.content != "")
    student.content.chomp
  end.compact

  [
    file,
    Set.new(s["students"].map{|x| x["login_id"] unless x["login_id"] == ""}.compact),
    Set.new(should_be_students)
  ]
end.compact

puts "=========================================================="

lists.each do |file, enrolled, should_be_enrolled|
  puts "For #{file}:"
  puts "  Enrolled, but shouldn't be:"
  (enrolled - should_be_enrolled).each do |student|
    puts "    #{student}"
  end
  puts "  Not enrolled, but should be:"
  (should_be_enrolled - enrolled).each do |student|
    puts "    #{student}"
  end
end
