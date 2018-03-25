require 'bundler/setup'
Bundler.require

open('font_list.txt', 'w') do |f|
  Magick.fonts.each do |font|
    f.puts font.name
  end
end