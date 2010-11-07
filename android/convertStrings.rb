#!/usr/bin/ruby

# iPhone の Localizable.strings から Android の strings.xml を生成する

puts "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
puts "<resources>"

ARGF.each do |line|
    if (line =~ /\"(.*)\"\s*=\s*\"(.*)\"/)
        tag = $1
        value = $2
        
        tag.gsub!(/ /, "_")
        tag.downcase!
        
        value.gsub!(/&/, "&amp;")
        puts "  <string name=\"#{tag}\">#{value}</string>"
    end
end

puts "</resources>"


