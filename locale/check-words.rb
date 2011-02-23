#!/usr/bin/ruby

def LoadFile(filename)
    words = Array.new
    open(filename) do |f|
        f.each do |line|
            if (line =~ /^"([^"]+)"/)
                words.push($1)
            end
        end
    end
    words
end


# start

if ARGV.count != 1
   puts "Usage: #{$0} <lang>"
   exit 1
end

# load
w1 = LoadFile("English.lproj/Localizable.strings")
w2 = LoadFile("#{ARGV[0]}.lproj/Localizable.strings")

ww = w1 - w2
if ww.length > 0
    puts "Not contained:"
    puts "  " + ww.join(",")
end

ww = w2 - w1
if ww.length > 0
    puts "Badly contained:"
    puts "  " + ww.join(",")
end
