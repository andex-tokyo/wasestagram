require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

def draw_text(draw, x, y, text, size=23.5 , color='black', font="/app/public/fonts/Yu_Gothic.otf")
  draw.font = font
  draw.pointsize = size
  draw.stroke(color)
  draw.text(x, y, text)
end

def draw_hash(draw, x, y, text, size=23.5 , color='#005c9b', font="/app/public/fonts/Yu_Gothic.otf")
  draw.font = font
  draw.pointsize = size
  draw.stroke(color)
  draw.text(x, y, text)
end


get '/' do
  erb :index
end

post '/pic' do
  @ip = request.ip
  picPath = "/tmp/posted_#{@ip}.jpg"
  profilePath = "/tmp/profile_#{@ip}.jpg"
  image = params[:pic][:tempfile]
  profile = params[:profile][:tempfile]
  name = params[:name]
  comment = params[:comment]
  good = params[:good]
  tag = params[:tags]
  open(picPath, 'wb') do |output|
    open(image) do |data|
      output.write(data.read)
      original = Magick::Image.read(picPath).first
      front = original.resize_to_fit(590, 400)
      back = Magick::Image.read('public/frame.jpg').first
      width = 297.5 - (front.columns/2)
      height = 300 - (front.rows/2)
      posted = back.composite(front, width , height, Magick::OverCompositeOp)
      open(profilePath, 'wb') do |profileOutput|
        open(profile) do |profileData|
          profileOutput.write(profileData.read)
          mask= Magick::Image.read('public/mask.png').first
          proOriginal = Magick::Image.read(profilePath).first
          proFront = proOriginal.resize(51, 51)
          masked = mask.composite(proFront, 0, 0, Magick::SrcInCompositeOp)
          icon = posted.composite(masked, 511 , 784, Magick::OverCompositeOp)
          result = icon.composite(masked, 30 , 117, Magick::OverCompositeOp)
          user = Magick::Draw.new
          draw_text(user, 98,145,name)
          user2 = Magick::Draw.new
          draw_text(user2, 32,723,name)
          namewidth = user2.get_type_metrics(name).width
          iine = Magick::Draw.new
          draw_text(iine, 135,688,good)
          comments = Magick::Draw.new
          draw_text(comments,45 + namewidth,723,comment)
          hash =  Magick::Draw.new
          draw_hash(hash,32 ,760,tag)
          user.draw(result)
          user2.draw(result)
          iine.draw(result)
          comments.draw(result)
          hash.draw(result)
          result.write("/tmp/result_#{@ip}.jpg")
        end
      end
    end
  end
  send_file("/tmp/result_#{@ip}.jpg")
end