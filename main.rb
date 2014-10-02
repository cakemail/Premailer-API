require 'sinatra'
require 'premailer'
require 'json'
require 'syslog-logger'

configure :production do
  set :port, 80
end

get '/clean' do
<<-eos
  <form method="POST">
  <textarea name="html"></textarea>
  <button>Submit</button>
  <div>With warnings?:
  <input type="checkbox" name="with_warnings" value="1"/>
  </div>
  <div>Remove comments:
  <input type="checkbox" name="remove_comments" value="1"/>
  </div>
  <div>Remove script tags:
  <input type="checkbox" name="remove_script_tags" value="1"/>
  </div>
  </form>
eos
end

post '/clean' do
  error 400 if !params[:html]

  logger = Logger::Syslog.new('premailer', Syslog::LOG_LOCAL7)
  logger.info { "pid:#{$$} " +  @params.inspect }

  with_warnings = params[:with_warnings] == '1' ? true : false
  remove_comments = params[:remove_comments] == '1' ? true : false
  remove_script_tags = params[:remove_script_tags] == '1' ? true : false
  html = params[:html]

  premailer = Premailer.new(html,
    :warn_level => Premailer::Warnings::SAFE,
    :with_html_string => true,
    :preserve_styles => true,
    :remove_comments => remove_comments,
    :remove_script_tags => remove_script_tags
  )

  content_type :json
  data = {:html => premailer.to_inline_css}
  data[:warnings] = premailer.warnings if with_warnings
  data.to_json
	logger.info { "pid:#{$$} returned" }
end
