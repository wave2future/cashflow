#!/usr/bin/ruby
# -*- coding: utf-8 -*-

def hsv2rgb(h,s,v)
  hi = (h / 60).to_i
  f = h / 60.0 - hi
  p = v * (1.0 - s)
  q = v * (1.0 - f * s)
  t = v * (1.0 - (1.0 - f) * s)
  
  r = 0
  g = 0
  b = 0

  case hi % 6
  when 0
    r = v; g = t; b = p
  when 1
    r = q; g = v; b = p
  when 2
    r = p; g = v; b = t
  when 3
    r = p; g = q; b = v
  when 4
    r = t; g = p; b = v
  when 5
    r = v; g = p; b = q
  end

  r = (255 * r).to_i
  g = (255 * g).to_i
  b = (255 * b).to_i

  code = sprintf("#%02x%02x%02x", r, g, b)
  return code
end

puts <<EOF
<!DOCTYPE html>
<html>
<head>
<meta charset=utf-8>
</head>
<body>
EOF

s = 0.8
v = 0.9

(0..100).each do |i|
  h = 30 + i * 78
  
  code = hsv2rgb(h, s, v)

  puts "<font color=\"#{code}\">■</font>"
  puts "H=#{h % 360}<br>"
end

puts <<EOF
</body>
</html>
EOF




