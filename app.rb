ENV['RACK_ENV'] ||= 'development'
ENV['APP_ENV']  ||= 'development'
require 'bundler/setup'
Bundler.require
require 'dotenv/load'                 # .env を自動で読む（dotenv）
require 'sinatra'
enable :sessions
require './models.rb'
require 'sinatra/activerecord'    
configure :development do
  require 'sinatra/reloader'
end
require 'cloudinary'
Cloudinary.config do |config|
config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']
config.api_key = ENV['CLOUDINARY_API_KEY']
config.api_secret = ENV['CLOUDINARY_API_SECRET']
end

CLOCK_IMAGE_FILES = {
    1 => 'one.gif',
    2 => 'two.gif',
    3 => 'three.gif',
    4 => 'four.gif',
    5 => 'five.gif',
    6 => 'six.gif',
    7 => 'seven.gif',
    8 => 'eight.gif',
    9 => 'nine.gif',
    10 => 'ten.gif',
    11 => 'eleven.gif',
    12 => 'twelve.gif'
}.freeze

helpers do
    def day_time_style(time_data)
        style = time_data.is_a?(Hash) ? time_data['style'].to_s.downcase : time_data.to_s.downcase
        return 'clock' if style == 'clock' || style == 'image'
        return 'hiragana' if style == 'hiragana'

        'kanji'
    end

    def day_time_value(time_data)
        return '' unless time_data.is_a?(Hash)

        value = time_data['timeValue'].to_s
        return value if value.match?(/\A\d{1,2}\z/)
        return value.split(':').first if value.match?(/\A\d{1,2}:\d{2}\z/)


        hour = time_data['time'].to_s[/\d+/]
        return '' if hour.nil?

        hour
    end

    def clock_image_path(time_data)
        value = day_time_value(time_data)
        return nil if value.empty?

        hour = value.to_i % 12
        hour = 12 if hour.zero?
        "/clock_images/#{CLOCK_IMAGE_FILES[hour]}"
    end

    def day_time_text(time_data)
        return '' unless time_data.is_a?(Hash)

        time_data['time'].to_s
    end
end

get '/' do
    erb :signin
end

get '/signup' do
    erb :signup
end

get '/signin' do
    erb :signin
end

get '/edit_about_day/:user_id' do
    @user = User.find(params[:user_id])
    @today = Date.today
    @type = "day"
    erb :edit_about_day
end

get '/edit_about_week/:user_id' do
    @user = User.find(params[:user_id])
    @today = Date.today
    @type = "week"
    erb :edit_about_week
end

get '/edit_about_month/:user_id' do
    @user = User.find(params[:user_id])
    @today = Date.today
    @type = "month"
    erb :edit_about_month
end

get '/newcreate_day/:user_id' do
    @user = User.find(params[:user_id])
    calendar_color = session[:colors]
    
    if calendar_color == "7colors"
    @color1 = "#ffe5fb"   # さらに薄く
    @color2 = "#eaddff"      # さらに薄く
    @color3 = "#dff9ff"
    @color4 = "#efffdf"
    @color5 = "#fffadf"
    @color6 = "#ffeadf"
    @color7 = "#ffdfdf"
    end
    
    @time_display = session[:time_display]
    @calendar_display = session[:date_display]
    @calendar_name = session[:calendar_name]
    @start_day = Date.parse(session[:start_day])
    @type = "day"
    @images = @user.logos
  
    erb :edit_main_day
end

get '/newcreate_week/:user_id' do
    @user = User.find(params[:user_id])
    calendar_color = session[:colors]
    
    if calendar_color == "3colors"
    @saturday_color = "#bfddff"   # さらに薄く
    @sunday_color = "#ffdfdf"      # さらに薄く
    elsif calendar_color == "7colors"
    @monday_color = "#ffe5fb"      # さらに薄く
    @tuesday_color = "#eaddff"     # さらに薄く
    @wednesday_color = "#dff9ff"   # さらに薄く
    @thursday_color = "#efffdf"    # さらに薄く
    @friday_color = "#fffadf"      # さらに薄く
    @saturday_color = "#ffeadf"    # さらに薄く
    @sunday_color = "#ffdfdf"      # さらに薄く
    end
    
    
    @calendar_display = session[:display]
    @calendar_name = session[:calendar_name]
    @start_day = session[:start_day]
    @type = "week"
    @images = @user.logos
  
    erb :edit_main_week
end

get '/newcreate_month/:user_id' do
    @user = User.find(params[:user_id])
    calendar_color = session[:colors]
    
    if calendar_color == "3colors"
    @saturday_color = "#bfddff"   # さらに薄く
    @sunday_color = "#ffdfdf"      # さらに薄く
    elsif calendar_color == "7colors"
    @monday_color = "#ffe5fb"      # さらに薄く
    @tuesday_color = "#eaddff"     # さらに薄く
    @wednesday_color = "#dff9ff"   # さらに薄く
    @thursday_color = "#efffdf"    # さらに薄く
    @friday_color = "#fffadf"      # さらに薄く
    @saturday_color = "#ffeadf"    # さらに薄く
    @sunday_color = "#ffdfdf"      # さらに薄く
    end
    
    @image_slot_count = session[:image_slot_count] || 1
    @calendar_display = session[:display]
    @calendar_name = session[:calendar_name]
    @year =session[:year]
    @month = session[:month]
    @date = session[:selected_month]
    @type = "month"
    @images = @user.logos
  
    erb :edit_main_month
end

get '/reedit_week/:user_id/:calendar_id' do
    
  @calendar_id = Calendar.find(params[:calendar_id])

  # calendar_info は JSON文字列で入っているのでそのまま parse
  @calendar = JSON.parse(@calendar_id.calendar_info)

  @calendar_name = @calendar_id.calendar_name
  @start_day = @calendar_id.start_day
  calendar_color = @calendar_id.color
  @calendar_display = @calendar_id.display
  @user = User.find(params[:user_id])
  @images = @user.logos
  
    if calendar_color == "3colors"
    @saturday_color = "#bfddff"
    @sunday_color = "#ffdfdf"
    elsif calendar_color == "7colors"
    @monday_color = "#ffe5fb"      
    @tuesday_color = "#eaddff"     
    @wednesday_color = "#dff9ff"  
    @thursday_color = "#efffdf"    
    @friday_color = "#fffadf"      
    @saturday_color = "#ffeadf"   
    @sunday_color = "#ffdfdf"     
    end
  erb :reedit_main_week
end

get '/reedit_day/:user_id/:calendar_id' do
  @calendar_id = Calendar.find(params[:calendar_id])

  # calendar_info は JSON文字列で入っているのでそのまま parse
  @calendar = JSON.parse(@calendar_id.calendar_info)

  @user = @calendar_id.user_id
  @calendar_name = @calendar_id.calendar_name
  @start_day = @calendar_id.start_day
  calendar_color = @calendar_id.color
  @calendar_display = @calendar_id.display
  @user = User.find(params[:user_id])
  @images = @user.logos
  
    if calendar_color == "7colors"
    @color1 = "#ffe5fb"   # さらに薄く
    @color2 = "#eaddff"      # さらに薄く
    @color3 = "#dff9ff"
    @color4 = "#efffdf"
    @color5 = "#fffadf"
    @color6 = "#ffeadf"
    @color7 = "#ffdfdf"
    end
    
  erb :reedit_main_day
end

get '/reedit_month/:user_id/:calendar_id' do
    
  @calendar_id = Calendar.find(params[:calendar_id])

  # calendar_info は JSON文字列で入っているのでそのまま parse
  @calendar = JSON.parse(@calendar_id.calendar_info)

  @calendar_name = @calendar_id.calendar_name
  @start_day = @calendar_id.start_day
  calendar_color = @calendar_id.color
  @calendar_display = @calendar_id.display
  @user = User.find(params[:user_id])
  @images = @user.logos
  @image_slot_count = [[@calendar_id.image_slot_count.to_i, 1].max, 2].min
  
    if calendar_color == "3colors"
    @saturday_color = "#bfddff"
    @sunday_color = "#ffdfdf"
    elsif calendar_color == "7colors"
    @monday_color = "#ffe5fb"      
    @tuesday_color = "#eaddff"     
    @wednesday_color = "#dff9ff"  
    @thursday_color = "#efffdf"    
    @friday_color = "#fffadf"      
    @saturday_color = "#ffeadf"   
    @sunday_color = "#ffdfdf"     
    end
  erb :reedit_main_month
end

get '/show_week/:user_id' do
    @user = User.find(params[:user_id])
    @calendar_week = @user.calendars.where(user_id: @user.id,calendar_type: "week").order(id: :desc)
    erb :show_week
end

get '/show_day/:user_id' do
    @user = User.find(params[:user_id])
    @calendar_day = @user.calendars.where(user_id: @user.id,calendar_type: "day").order(id: :desc)
    erb :show_day
end

get '/show_month/:user_id' do
    @user = User.find(params[:user_id])
    @calendar_month = @user.calendars.where(user_id: @user.id,calendar_type: "month").order(id: :desc)
    erb :show_month
end

# get '/howto' do
#     erb :howto
# end

# get '/team' do
#     erb :team
# end

get '/setting/:user_id' do
    @user = User.find(params[:user_id])
    erb :setting
end

post '/signup' do
    user = User.create(mail: params[:mail],password: params[:password])
    if user.persisted?
        redirect "/show_day/#{user.id}"
    else
        redirect "/signup"
    end
end

post '/signin' do
    userfind = User.find_by(mail: params[:mail],password: params[:password])
    if userfind.nil?
        redirect "/"
    end
    redirect "/show_day/#{userfind.id}"
    erb :home
end

post '/newcreate_day/:user_id' do
    session[:calendar_name] = params[:calendar_name]
    session[:start_day] = params[:selected_date]
    session[:colors] = params[:color]
    session[:date_display] = params[:date_display]
    session[:time_display] = params[:time_display]
    user = User.find(params[:user_id])

    redirect "/newcreate_day/#{user.id}"
end

post '/newcreate_week/:user_id' do
    session[:calendar_name] = params[:calendar_name]
    session[:start_day] = params[:selected_date]
    session[:colors] = params[:color]
    session[:display] = params[:display]
    user = User.find(params[:user_id])

    redirect "/newcreate_week/#{user.id}"
end

post '/newcreate_month/:user_id' do
    session[:calendar_name] = params[:calendar_name]
    session[:display] = params[:display]
    session[:colors] = params[:color]
    user = User.find(params[:user_id])
    session[:image_slot_count] = params[:howmany] == "two" ? 2 : 1
    
    selected_month = params[:selected_month] # 例: "2026-08"
    year, month = selected_month.split("-")

    session[:selected_month] = selected_month # "2026-08"
    session[:year] = year                     # "2026"
    session[:month] = month                   # "08"

    redirect "/newcreate_month/#{user.id}"
end

post '/calendar_week/:user_id' do
    data = request.body.read
    user = User.find(params[:user_id])
    
    user.calendars.create(calendar_name: session[:calendar_name],calendar_type: "week",start_day: session[:start_day],
                         color: session[:colors],display: session[:display],calendar_info: data,day: Date.today)
    content_type :json
    { redirect_to: "/show_week/#{user.id}" }.to_json
end

post '/calendar_day/:user_id' do
    data = request.body.read
    user = User.find(params[:user_id])
    
    user.calendars.create(calendar_name: session[:calendar_name],calendar_type: "day",start_day: session[:start_day],
                         color: session[:colors],display: session[:date_display],calendar_info: data,day: Date.today)
    content_type :json
    { redirect_to: "/show_day/#{user.id}" }.to_json
end

post '/calendar_month/:id' do
    data = request.body.read
    user = User.find(params[:id])
    first_day = Date.parse("#{session[:selected_month]}-01")
    user.calendars.create(calendar_name: session[:calendar_name],calendar_type: "month",start_day: first_day,
                         color: session[:colors],display: session[:display],calendar_info: data,day: Date.today,
                         image_slot_count: session[:image_slot_count] || 1)
    content_type :json
    { redirect_to: "/show_month/#{user.id}" }.to_json
end

# こんな感じでuserの情報を必ずとる
# パスにuserの情報を入れる
post '/recalendar_week/:user_id/:calendar_id' do
    data = request.body.read
    calendar = Calendar.find(params[:calendar_id])
    user = params[:user_id]
    calendar.update(calendar_info: data)
    content_type :json
    { redirect_to: "/show_week/#{user}" }.to_json
end

post '/recalendar_day/:user_id/:calendar_id' do
    data = request.body.read
    calendar = Calendar.find(params[:calendar_id])
    user = params[:user_id]
    calendar.update(calendar_info: data)
    content_type :json
    { redirect_to: "/show_day/#{user}" }.to_json
end

post '/recalendar_month/:user_id/:calendar_id' do
    data = request.body.read
    calendar = Calendar.find(params[:calendar_id])
    user = params[:user_id]
    calendar.update(calendar_info: data)
    content_type :json
    { redirect_to: "/show_month/#{user}" }.to_json
end

post '/upload_image/:user_id' do
    user = User.find(params[:user_id])
    # params[:images]で複数取得できるが、保険としてparams[:image]も残しているだけ
    raw_images = params[:images] || params[:image]
    # raw_imagesがもし配列になっていなかったら配列にして、配列からnilを排除して条件に合うものを取得する
    uploaded_files = (raw_images.is_a?(Array) ? raw_images : [raw_images]).compact.select do |image|
        # 条件はハッシュでtempfileが存在すること
        image.is_a?(Hash) && (image[:tempfile] || image['tempfile'])
    end
    # リダイレクト先取得
    return_to = params[:return_to].to_s
    # リダイレクトパスを作る。
    # 取得したパスが/から始まっているかつ//では始まらないなら、return_toをそのままパスとして使って、そうじゃないならdayに飛ぶ
    redirect_path = return_to.start_with?('/') && !return_to.start_with?('//') ? return_to : "/edit_about_day/#{user.id}"

    if uploaded_files.empty?
        "ファイルが選択されていません"
    else
        logos = uploaded_files.map do |image|
		        # tempgfile取得
            tempfile = image[:tempfile] || image['tempfile']
            # Cloudinaryにあげて、url取得
            result = Cloudinary::Uploader.upload(tempfile.path)
            # urlをlogoテーブルに保存
            user.logos.create(images: result['secure_url'])
        end

        if logos.all?(&:persisted?)
            redirect redirect_path
        else
            "データベースに保存できませんでした"
        end
    end
end

post '/print/:user_id' do
    # calendar = Calendar.find(params[:calendar_id])
    user = params[:user_id]
    redirect "/show/#{user}"
end

post '/pdf_keep/:user_id' do
    # calendar = Calendar.find(params[:id])
    user = params[:user_id]
    redirect "/show/#{user}"
end

# post '/template/:id' do
#     calendar = Calendar.find(params[:id])
#     calendar.update(template: true)
#     user = calendar.user_id
#     redirect "/show/#{user}"
# end

post '/create_username/:user_id' do
    user = User.find(params[:user_id])
    user.update(name: params[:name])
    redirect "/setting/#{user.id}"
end

post '/calendar_name/:user_id/:calendar_id' do
    content_type :json
    user = User.find(params[:user_id])
    calendar = user.calendars.find(params[:calendar_id])
    calendar_name = params[:calendar_name].to_s.strip

    if calendar_name.empty?
        status 422
        { error: "カレンダー名を入力してください" }.to_json
    elsif calendar.update(calendar_name: calendar_name)
        { calendar_name: calendar.calendar_name }.to_json
    else
        status 422
        { error: "カレンダー名を保存できませんでした" }.to_json
    end
rescue ActiveRecord::RecordNotFound
    status 404
    { error: "カレンダーが見つかりませんでした" }.to_json
end