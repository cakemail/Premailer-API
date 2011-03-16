require 'sinatra'
require 'premailer'
require 'json'

configure :production do
  set :port, 80
end

get '/premailer' do
<<-eos
  <form method="POST">
  <textarea name="html"></textarea>
  <button>Submit</button>
  <input type="hidden" name="with_warnings" value="1"/>
  </form>
eos
end

post '/premailer' do
  error 400 if !params[:html]

  with_warnings = params[:with_warnings] == '1' ? true : false
  html = params[:html]

  premailer = Premailer.new(html, :warn_level => Premailer::Warnings::SAFE, :with_html_string => true)

  content_type :json
  data = {:html => premailer.to_inline_css}
  data[:warnings] = premailer.warnings if with_warnings
  data.to_json
end
