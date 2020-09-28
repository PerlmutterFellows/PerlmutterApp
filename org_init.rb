require "rubygems"
require "tty-prompt"
require "tty-command"
require "tty-file"
require "tty-box"
require "tty-config"
require "tty-link"
require "tty-spinner"
require "net/smtp"
require "twilio-ruby"
require "platform-api"
require "git"
require "yaml"
require "json"
require "optparse"
require "rmagick"

public

# Wrap text body for terminal display
def wrap(body)
  separator = " "
  words = body.split(separator)
  sentences = []
  sentence = []
  words.each do |word|
    sentence.push(word)
    if (sentence).join(separator).length > 75
      sentence.pop
      sentences.push(sentence.join(separator))
      sentence = [word]
    end
  end
  if sentence.length > 0
    sentences.push(sentence.join(separator))
  end
  sentences.join("\n")
end

# Output text with loader for terminal display
def loader(body, time)
  pastel = Pastel.new
  spinner = TTY::Spinner.new(pastel.blue(":spinner :text :spinner "), format: :dots_2)
  spinner.auto_spin
  if !time.nil?
    time.downto(0) do |sec|
      spinner.update(text: "#{body} (Est. #{sec}s)")
      sleep(1)
    end
  else
    spinner.update(text: "#{body}")
  end
  spinner
end

# Helpers for colored terminal box display
def box(body)
  formatted_box(body, :blue, "ℹ", "")
end

def prompt_box(body)
  formatted_box(body, :blue, TTY::Prompt::Symbols.symbols[:ellipsis], "Prompt")
end

def error_box(body)
  formatted_box(body, :red, TTY::Prompt::Symbols.symbols[:cross], "Error")
end

def success_box(body)
  formatted_box(body, :green, TTY::Prompt::Symbols.symbols[:tick], "Success")
end

def success_prompt(body)
  unless body == ""
    body = " #{body}"
  end
  @prompt.keypress(success_box("Success!#{body} Please continue by pressing any key, or by waiting 5 seconds."), timeout: 5)
end

def formatted_box(body, color, prefix, suffix)
  title = "Perlmutter App"
  unless prefix == ""
    title = "#{prefix} #{title}"
  end
  unless suffix == ""
    title = "#{title} #{suffix}"
  end
  puts(TTY::Box.frame(align: :center,
                      padding: 1,
                      title: {top_left: " #{title} ", bottom_right: " #{title} "},
                      style: {fg: color, bg: :black, border: {fg: color, bg: :black}}) { "#{wrap(body)}" })
end

# Gets requested arg from runtime args
def get_argument_value(arg, required, fallback)
  if @args.has_key?(arg)
    @args[arg]
  else
    raise ArgumentError, "Required argument #{arg} is blank" if required
    fallback
  end
end

# Configure organization information and contact details
def configure_information
  @config["config"]["contact"] = {}
  if @args.empty?
    @config["config"]["organization_name"] = @prompt.ask(prompt_box("What is your organization\'s name?"), required: true)
    @config["config"]["organization_description"] = @prompt.ask(prompt_box("What is your organization\'s description?"))
    @config["config"]["organization_domain"] = @prompt.ask(prompt_box("What is your organization\'s custom URL that you would like to host the app at? (ex. demo.perlmutterapp.com) Leave blank to use the default instead."))
    prefs = @prompt.multi_select(prompt_box("Please select contact preferences to configure for your users to view:"), %W[email phone facebook twitter instagram website])
    if prefs.include? "email"
      @config["config"]["contact"]["email"] = @prompt.ask(prompt_box("What is your contact email?"), default: @config["config"]["contact"]["email"], required: true) { |q| q.validate :email, "Invalid email" }
    end
    if prefs.include? "phone"
      @config["config"]["contact"]["phone"] = @prompt.ask(prompt_box("What is your contact phone?"), default: @config["config"]["contact"]["phone"], required: true)
    end
    if prefs.include? "facebook"
      @config["config"]["contact"]["facebook"] = @prompt.ask(prompt_box("What is your Facebook account?"), default: @config["config"]["contact"]["facebook"], required: true)
    end
    if prefs.include? "twitter"
      @config["config"]["contact"]["twitter"] = @prompt.ask(prompt_box("What is your Twitter account?"), default: @config["config"]["contact"]["twitter"], required: true)
    end
    if prefs.include? "instagram"
      @config["config"]["contact"]["instagram"] = @prompt.ask(prompt_box("What is your Instagram account?"), default: @config["config"]["contact"]["instagram"], required: true)
    end
    if prefs.include? "website"
      @config["config"]["contact"]["website"] = @prompt.ask(prompt_box("What is your external website?"), default: @config["config"]["contact"]["website"], required: true)
    end
  else
    @config["config"]["organization_name"] = get_argument_value("org_name", true, nil)
    description = get_argument_value("org_desc", false, nil)
    unless description.nil?
      @config["config"]["organization_description"] = description
    end
    domain = get_argument_value("org_domain", false, nil)
    unless domain.nil?
      @config["config"]["organization_domain"] = domain
    end
    email = get_argument_value("org_email", false, nil)
    unless email.nil?
      @config["config"]["contact"]["email"] = email
    end
    phone = get_argument_value("org_phone", false, nil)
    unless phone.nil?
      @config["config"]["contact"]["phone"] = phone
    end
    facebook = get_argument_value("org_facebook", false, nil)
    unless facebook.nil?
      @config["config"]["contact"]["facebook"] = facebook
    end
    twitter = get_argument_value("org_twitter", false, nil)
    unless twitter.nil?
      @config["config"]["contact"]["twitter"] = twitter
    end
    instagram = get_argument_value("org_instagram", false, nil)
    unless instagram.nil?
      @config["config"]["contact"]["instagram"] = instagram
    end
    website = get_argument_value("org_website", false, nil)
    unless website.nil?
      @config["config"]["contact"]["website"] = website
    end
  end
  success_prompt("Organization details configured.")
end

# Configure app colors
def configure_colors
  actual_path = "app/javascript/stylesheets/variables.scss"
  if @args.empty?
    variables_set = false
    until variables_set
      begin
        case @prompt.select(prompt_box("You may optionally provide your organization's primary and secondary colors to use for branding. Please pick whether you'd like to select your organization's colors or not:"), %W[Select Skip])
        when "Select"
          File.delete(actual_path) if File.exist?(actual_path)
          box("You will need your primary and secondary colors in hexadecimal format. You can find those #{TTY::Link.link_to("here.", "http://url.perlmutterapp.com/color")}")
          primary = @prompt.ask(prompt_box("What is the primary color? (Typically a black/gray shade)"), default: "#000000", required: true)  { |q| q.validate /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/m, "Invalid hex color" }
          secondary = @prompt.ask(prompt_box("What is the secondary color? (Typically a colorful shade)"), default: "#033473", required: true)  { |q| q.validate /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/m, "Invalid hex color" }
          TTY::File.create_file actual_path, "$primary: #{primary};\n$secondary: #{secondary};"
          success_prompt("Colors set.")
          variables_set = true
        else
          success_prompt("Setting colors skipped.")
          break
        end
      rescue StandardError
        error_box("Setting colors failed. Please try again. If this persists, please reach out to the developers.")
      end
    end
  else
    File.delete(actual_path) if File.exist?(actual_path)
    primary = get_argument_value("color_primary", false, "#000000")
    secondary = get_argument_value("color_secondary", false, "#033473")
    begin
      TTY::File.create_file actual_path, "$primary: #{primary};\n$secondary: #{secondary};"
      success_prompt("Colors set.")
    rescue StandardError
      error_box("Setting colors failed.")
      raise ArgumentError
    end
  end
end

# Generate favicon images from logo SVG
def write_png_from_svg(input, output, width, height)
  success = true
  begin
    Magick::Image.read(input).first.resize(width, height).write(output)
  rescue
    success = false
  end
  success
end

# Configure app logo and favicon
def configure_logo
  actual_path = "app/javascript/svgs/logo.svg"
  favicon_fallback_path = "app/assets/images/perlmutterapp.svg"
  favicon_path = "app/assets/images/favicon.svg"
  apple_icon_path = "app/assets/images/favicon.png"
  webpack_path = "media/svgs/logo.svg"
  if @args.empty?
    while @config["config"]["logo_path"].nil?
      File.delete(actual_path) if File.exist?(actual_path)
      File.delete(favicon_path) if File.exist?(favicon_path)
      begin
        case @prompt.select(prompt_box("You may optionally provide your organization's logo in SVG format to use for branding. Please select an option to provide an SVG, or select from our presets:"), %W[URL Filepath Presets Skip])
        when "URL"
          TTY::File.download_file(@prompt.ask(prompt_box("What is the URL for the SVG?"), required: true), actual_path)
          TTY::File.copy_file(actual_path, favicon_path)
          @config["config"]["logo_path"] = webpack_path
        when "Filepath"
          TTY::File.copy_file(@prompt.ask(prompt_box("What is the filepath for the SVG?"), required: true), actual_path)
          TTY::File.copy_file(actual_path, favicon_path)
          @config["config"]["logo_path"] = webpack_path
        when "Presets"
          emoji_map = JSON.parse(File.open("emoji.json", "rb").read).to_h { |h| [h["name"], h["codes"].gsub(' ', '-').downcase] }
          code = @prompt.select(prompt_box("Select from online presets to be your logo! If unavailable, try another:"), emoji_map, filter: true, required: true)
          TTY::File.download_file("https://twemoji.maxcdn.com/svg/#{code}.svg", actual_path)
          TTY::File.copy_file(actual_path, favicon_path)
          @config["config"]["logo_path"] = webpack_path
        else
          success_prompt("Setting logo skipped.")
          TTY::File.copy_file(favicon_fallback_path, favicon_path)
          break
        end
        unless @config["config"]["logo_path"].nil?
          success_prompt("Logo set.")
        end
      rescue StandardError
        error_box("Setting logo failed. Please try again. If this persists, please reach out to the developers.")
      end
    end
  else
    File.delete(actual_path) if File.exist?(actual_path)
    File.delete(favicon_path) if File.exist?(favicon_path)
    logo = get_argument_value("logo", false, nil)
    option = get_argument_value("logo_option", false, nil)
    if !logo.nil? && !option.nil?
      begin
        case option
        when "url"
          TTY::File.download_file(logo, actual_path)
        else
          TTY::File.copy_file(logo, actual_path)
        end
        TTY::File.copy_file(actual_path, favicon_path)
        @config["config"]["logo_path"] = webpack_path
        success_prompt("Logo set.")
      rescue StandardError
        error_box("Setting logo failed.")
        raise ArgumentError
      end
    else
      success_prompt("Setting logo skipped.")
      TTY::File.copy_file(favicon_fallback_path, favicon_path)
    end
  end
  write_png_from_svg(favicon_path, apple_icon_path, 180, 180)
end

# Helper for testing SMTP settings
def verify_email
  smtp_verified = false
  begin
    smtp = Net::SMTP.new(@config["config"]["smtp"]["smtp_address"], @config["config"]["smtp"]["smtp_port"])
    smtp.enable_starttls
    smtp.start("localhost", @config["config"]["smtp"]["smtp_username"], @config["config"]["smtp"]["smtp_password"], :login)
    smtp_verified = true
    smtp.finish
    success_prompt("Email authenticated.")
  rescue StandardError => e
    if e.class == Net::SMTPAuthenticationError
      error_box("Authentication failed. Please verify your credentials/server settings and try again.")
    else
      error_box("Testing email failed. Please try again. If this persists, please reach out to the developers.")
    end
  end
  smtp_verified
end

# Configure app email/SMTP settings
def configure_email
  @config["config"]["smtp"] = {}
  if @config["config"]["contact"]["email"]
    @config["config"]["smtp"]["smtp_username"] = @config["config"]["contact"]["email"]
  end
  if @args.empty?
    box("You will now need an email to drive emails from the app. If you don't have one, register a Gmail #{TTY::Link.link_to("here.", "http://url.perlmutterapp.com/gmail")}")
    smtp_verified = false
    until smtp_verified
      @config["config"]["smtp"]["smtp_username"] = @prompt.ask(prompt_box("What is the email to send notifications from?"), default: @config["config"]["smtp"]["smtp_username"], required: true) { |q| q.validate :email, "Invalid email" }
      @config["config"]["smtp"]["smtp_password"] = @prompt.mask(prompt_box("What is the email\'s password?"), required: true)
      @config["config"]["smtp"]["smtp_port"] = 587
      case @prompt.select(prompt_box("Please select the email's provider to configure the app:"), %W[Gmail Yahoo AOL Outlook Office365 Other])
      when "Gmail"
        @config["config"]["smtp"]["smtp_address"] = "smtp.gmail.com"
      when "Yahoo"
        @config["config"]["smtp"]["smtp_address"] = "smtp.mail.yahoo.com"
        @config["config"]["smtp"]["smtp_port"] = 465
      when "AOL"
        @config["config"]["smtp"]["smtp_address"] = "smtp.aol.com"
      when "Outlook"
        @config["config"]["smtp"]["smtp_address"] = "smtp.live.com"
      when "Office365"
        @config["config"]["smtp"]["smtp_address"] = "smtp.office365.com"
      else
        box("You will now need the email\'s SMTP settings. You can get help finding these #{TTY::Link.link_to("here.", "http://url.perlmutterapp.com/smtp")}")
        @config["config"]["smtp"]["smtp_address"] = @prompt.ask(prompt_box("What is the email\'s SMTP address?"), default: @config["config"]["smtp"]["smtp_address"], required: true)
        @config["config"]["smtp"]["smtp_port"] = @prompt.ask(prompt_box("What is the email\'s SMTP port?"), default: @config["config"]["smtp"]["smtp_port"], convert: :int, required: true) { |q| q.validate /\A\d+\z/, "Must be integer" }
      end
      smtp_verified = verify_email
    end
  else
    @config["config"]["smtp"]["smtp_username"] = get_argument_value("smtp_username", true, nil)
    @config["config"]["smtp"]["smtp_password"] = get_argument_value("smtp_password", true, nil)
    @config["config"]["smtp"]["smtp_address"] = get_argument_value("smtp_address", true, nil)
    @config["config"]["smtp"]["smtp_port"] = get_argument_value("smtp_port", false, 587)
    smtp_verified = verify_email
    unless smtp_verified
      raise ArgumentError
    end
  end
end

# Helper for testing Twilio settings
def verify_phone
  phone_verified = false
  begin
    @client = Twilio::REST::Client.new(@config["config"]["phone"]["account_sid"], @config["config"]["phone"]["auth_token"])
    phone_numbers = @client.incoming_phone_numbers.list
    if phone_numbers.empty?
      @config["config"]["phone"]["phone_number"] = @client.available_phone_numbers("US").local.list.first.phone_number
      @config["config"]["phone"]["phone_sid"] = @client.incoming_phone_numbers.create(phone_number: @config["config"]["phone"]["phone_number"]).sid
      box("Acquired phone number.")
    else
      @config["config"]["phone"]["phone_number"] = phone_numbers.first.phone_number
      @config["config"]["phone"]["phone_sid"] = phone_numbers.first.sid
      box("Already have phone number.")
    end
    phone_verified = true
    success_prompt("Twilio authenticated. Phone Number: #{@config["config"]["phone"]["phone_number"]} Phone SID: #{@config["config"]["phone"]["phone_sid"]}")
  rescue StandardError
    error_box("Testing Twilio failed. Please try again. If this persists, please reach out to the developers.")
  end
  phone_verified
end

# Configure app Twiliio settings
def configure_phone
  @config["config"]["phone"] = {}
  if @args.empty?
    box("You will now need to register a Twilio account to drive texts/calls from the app, upgrade it past the free trial by providing payment information, and input the account SID and auth token. You can do so #{TTY::Link.link_to("here.", "http://url.perlmutterapp.com/twilio")}")
    phone_verified = false
    until phone_verified
      @config["config"]["phone"]["account_sid"] = @prompt.ask(prompt_box("What is your Twilio account SID?"), required: true)
      @config["config"]["phone"]["auth_token"] = @prompt.ask(prompt_box("What is your Twilio auth token?"), required: true)
      phone_verified = verify_phone
    end
  else
    @config["config"]["phone"]["account_sid"] = get_argument_value("account_sid", true, nil)
    @config["config"]["phone"]["auth_token"] =  get_argument_value("auth_token", true, nil)
    phone_verified = verify_phone
    unless phone_verified
      raise ArgumentError
    end
  end
end

# Configure app FAQ
def configure_faq
  if @args.empty?
    if @config["faq"].nil?
      @config["faq"] = []
      continue = "Create"
      stop = "Skip"
    else
      continue = "Continue"
      stop = "Finish"
    end
    if @prompt.select(prompt_box("Please select an option regarding your application's FAQ:")) do |menu|
      menu.choice name: continue, value: true
      menu.choice name: stop, value: false
    end
      question = @prompt.ask(prompt_box("Please input the question:"), required: true)
      answer = @prompt.ask(prompt_box("Please input the answer:"), required: true)
      entry = {
          question: question,
          answer: answer
      }
      @config["faq"].push(entry)
      configure_faq
    else
      choice = @config["faq"].empty? ? "skipped" : "created"
      success_prompt("FAQ #{choice}.")
    end
  else
    faq = get_argument_value("faq", false, nil)
    if !faq.nil? && !faq["faq"].empty?
      @config["faq"] = faq["faq"]
    end
    choice = faq.nil? || faq["faq"].empty? ? "skipped" : "created"
    success_prompt("FAQ #{choice}.")
  end
end

# Configure app form
def configure_form
  if @args.empty?
    if @config["form"].nil?
      @config["form"] = []
      continue = "Create"
      stop = "Skip"
    else
      continue = "Continue"
      stop = "Finish"
    end
    if @prompt.select(prompt_box("Please select an option regarding your application's form:")) do |menu|
      menu.choice name: continue, value: true
      menu.choice name: stop, value: false
    end
      if @config["config"]["form_name"].nil?
        @config["config"]["form_name"] = @prompt.ask(prompt_box("Please input the form's title:"), required: true)
      end
      entry = {}
      entry["question"] = @prompt.ask(prompt_box("Please input the question:"), required: true)
      prefs = @prompt.multi_select(prompt_box("Please select any additional extra options to configure for the question:"), %W[trigger subscores])
      if prefs.include? "trigger"
        entry["trigger"] = @prompt.ask(prompt_box("Please input the trigger:"), required: true)
      end
      if prefs.include? "subscores"
        subscores = []
        range = (@prompt.ask(prompt_box("Please input the number of subscores:"), required: true) { |q| q.validate /^[1-9]\d*$/m, "Must be positive integer" }).to_i
        (1..range).each do
          subscores.push(@prompt.ask(prompt_box("Please input the subscore:"), required: true))
        end
        entry["subscores"] = subscores
      end
      entry["max_value"] = 0
      answers = []
      range = (@prompt.ask(prompt_box("Please input the number of answers:"), required: true) { |q| q.validate /^[1-9]\d*$/m, "Must be positive integer" }).to_i
      (1..range).each do
        answer = {}
        answer["text"] = @prompt.ask(prompt_box("Please input the answer:"), required: true)
        prefs = @prompt.multi_select(prompt_box("Please select any additional extra options to configure for the answer:"), %W[value trigger])
        if prefs.include? "value"
          answer["value"] = @prompt.ask(prompt_box("Please input the value:"), required: true).to_i
          if answer["value"] > entry["max_value"]
            entry["max_value"] = answer["value"]
          end
        end
        if prefs.include? "trigger"
          answer["trigger"] = @prompt.ask(prompt_box("Please input the trigger:"), required: true)
        end
        answers.push(answer)
      end
      entry["answers"] = answers
      @config["form"].push(entry)
      configure_form
    else
      choice = @config["form"].empty? ? "skipped" : "created"
      success_prompt("Form #{choice}.")
    end
  else
    form_name = get_argument_value("form_name", false, nil)
    unless form_name.nil?
      @config["config"]["form_name"] = form_name
    end
    form = get_argument_value("form", false, nil)
    if !form.nil? && !form["form"].empty?
      @config["form"] = form["form"]
    end
    choice = form.nil? || form["form"].empty? ? "skipped" : "created"
    success_prompt("Form #{choice}.")
  end
end

# Configure app default admin user
def configure_admin
  @config["config"]["admin"] = {}
  if @args.empty?
    box("You will now need to input credentials for the admin user you would like to create.")
    @config["config"]["admin"]["email"] = @prompt.ask(prompt_box("What is your admin\'s email?"), default: @config["config"]["contact"]["email"], required: true) { |q| q.validate :email, "Invalid email" }
    @config["config"]["admin"]["password"] = @prompt.mask(prompt_box("What is your admin\'s password?"), required: true) { |q| q.validate /^.{6,}$/, "Must be at least 6 characters" }
    @config["config"]["admin"]["first_name"] = @prompt.ask(prompt_box("What is your admin\'s first name?"), required: true)
    @config["config"]["admin"]["last_name"] = @prompt.ask(prompt_box("What is your admin\'s last name?"), required: true)
  else
    @config["config"]["admin"]["email"] = get_argument_value("admin_email", true, nil)
    @config["config"]["admin"]["password"] = get_argument_value("admin_password", true, nil)
    @config["config"]["admin"]["first_name"] = get_argument_value("admin_first_name", false, "Admin")
    @config["config"]["admin"]["last_name"] = get_argument_value("admin_last_name", false, "User")
  end
  success_prompt("Admin user created.")
end

# Helper to save the config for a given locale
def save_config_file(locale, key)
  locale_config = {}
  locale_config[locale] = {}
  unless @config[key].nil?
    locale_config[locale][key] = @config[key]
    path = "config/locales/org/#{key}/#{locale}.yml"
    File.delete(path) if File.exist?(path)
    TTY::File.create_file(path, locale_config.to_yaml)
  end
end

# Save config generated for a specific locale
def output_config_for_locale(locale)
  save_config_file(locale, "config")
  save_config_file(locale, "faq")
  save_config_file(locale, "form")
end

# Helper to get Heroku app name
def get_heroku_app_name(name)
  if @args.empty?
    app_not_found = true
    while app_not_found
      app_case = @prompt.select(prompt_box("Please select whether you are creating a new app or updating an existing one:"), %W[Create Update])
      if app_case == "Create"
        name_prompt = "What would you like to name your app?"
        command_case = "create"
      else
        name_prompt = "What is your app's name?"
        command_case = "info"
      end
      begin
        @config["config"]["app_name"] = @prompt.ask(prompt_box(name_prompt), default: name, required: true) { |q| q.validate /^[a-z0-9]+$/m, "Must be lowercase alphanumeric only" }
        name = @config["config"]["app_name"]
        @cmd.run("heroku #{command_case} #{name}")
        app_not_found = false
      rescue TTY::Command::ExitError
        error_box("App #{command_case} failed. Please try a different name.")
      end
    end
  else
    command_case = get_argument_value("heroku_command", true, "info")
    begin
      @config["config"]["app_name"] = get_argument_value("heroku_app_name", true, nil)
      name = @config["config"]["app_name"]
      @cmd.run("heroku #{command_case} #{name}")
    rescue TTY::Command::ExitError
      error_box("App #{command_case} failed.")
      raise ArgumentError
    end
  end
  name
end

# Helper to get Heroku app URL
def get_heroku_app_url(name)
  if @config["config"]["organization_domain"]
    # Establishes a uniform prefix of http:// for whatever domain inputted
    domain_no_prefix = get_stripped_url(@config["config"]["organization_domain"], true)
    "http://#{domain_no_prefix}"
  else
    # Gets domain from Heroku
    url_str = @cmd.run("heroku info #{name}").out.lines[-1]
    url_str[url_str.rindex(' ')+1..-1].strip
  end
end

# Helper to strip a URL as needed downstream
def get_stripped_url(url, drop_prefix)
  result = url
  if drop_prefix && result.start_with?("http://", "https://")
    prefix = '://'
    result = result[result.rindex(prefix)+prefix.length, result.length]
  end
  if result.end_with?('/')
    result[0...-1]
  else
    result
  end
end

# Deploys an organization's app based on name and URL
def deploy_heroku(name, app_url)
  deploy_loader = loader("Deploying and running installation of app...", nil)
  branch_name = "#{name}#{Time.now.strftime("%d-%m-%Y-%H-%M")}"
  url = get_stripped_url(app_url, false)
  stripped_url = get_stripped_url(app_url, true)
  @cmd.run("rm -rf .git")
  @cmd.run("git init")
  @cmd.run("heroku git:remote -a #{name}")
  @cmd.run("heroku config:set SECRET_KEY_BASE=$(rake secret)") rescue TTY::Command::ExitError
  @cmd.run("heroku config:set APP_URL=#{url}") rescue TTY::Command::ExitError
  @cmd.run("heroku config:set APP_STRIPPED_URL=#{stripped_url}") rescue TTY::Command::ExitError
  unless @cmd.run("heroku addons").out.include? "heroku-redis"
    begin
      @cmd.run("heroku addons:create heroku-redis:hobby-dev")
    rescue TTY::Command::ExitError
      error_box("App #{name} failed. Please ensure that you are on the Hobby Dev payment tier or above.")
      raise ArgumentError
    end
  end
  unless @cmd.run("heroku domains -a #{name}").out.include? stripped_url
    begin
      @cmd.run("heroku domains:add #{stripped_url} -a #{name}")
    rescue TTY::Command::ExitError
      error_box("Setting custom URL #{stripped_url} failed.")
      raise ArgumentError
    end
  end
  unless @cmd.run("heroku buildpacks -a #{name}").out.include? "apt"
    begin
      @cmd.run("heroku buildpacks:add --index 1 https://github.com/heroku/heroku-buildpack-apt.git -a #{name}")
      @cmd.run("heroku buildpacks:add --index 2 heroku/ruby -a #{name}")
      @cmd.run("heroku config:set GI_TYPELIB_PATH=/app/.apt/usr/lib/x86_64-linux-gnu/girepository-1.0") rescue TTY::Command::ExitError
    rescue TTY::Command::ExitError
      error_box("Setting buildpacks failed.")
      raise ArgumentError
    end
  end

  @cmd.run("git config --global core.autocrlf true")
  @cmd.run("git checkout -b #{branch_name}")
  @cmd.run("git add .")
  @cmd.run("git add -f config")
  @cmd.run("git commit -m '#{name}'")
  @cmd.run("git push -f heroku #{branch_name}:main")
  deploy_loader.stop
  stripped_url
end

# Configures Heroku based on an org's config and deploys
def configure_heroku
  box("You will now need to register a Heroku account to host the app, and upgrade to the free Hobby Dev tier by providing payment information. You can do so #{TTY::Link.link_to("here.", "http://url.perlmutterapp.com/heroku")}")
  name = @config["config"]["app_name"].nil? ? @config["config"]["organization_name"].downcase.tr(" ", "") : @config["config"]["app_name"]
  begin
    @cmd.run("which heroku")
  rescue TTY::Command::ExitError
    @cmd.run("curl https://cli-assets.heroku.com/install.sh | sh")
  end
  @cmd.run("heroku login", input: "h")
  success_prompt("Heroku authenticated.")

  name = get_heroku_app_name(name)
  app_url = get_heroku_app_url(name)
  success_prompt("Heroku app configured. Beginning to deploy...")
  app_url = deploy_heroku(name, app_url)
  @cmd.run("heroku run:detached rake db:migrate -a #{name}")
  db_loader = loader("Almost there! Configuring database of app...", 60)
  db_loader.stop

  [name, app_url]
end

# Generates the config YMLs for an organization's app
def configure_organization
  configure_information
  configure_colors
  configure_logo
  configure_email
  configure_phone
  configure_faq
  configure_form
  configure_admin
  output_config_for_locale("en")
  output_config_for_locale("es")
  success_box("Your app is now configured!")
end

def get_heroku_dns_target(name, app_url)
  output = @cmd.run("heroku domains -a #{name}").out
  domain_line = output.lines.detect { |line| line.include?(app_url) && !line.include?("herokuapp.com") }
  if domain_line.nil?
    nil
  else
    domain_line[domain_line.rindex('CNAME')+'CNAME'.length..-1].strip
  end
end

# Deploys an organization's app
def deploy_organization
  name, app_url = configure_heroku
  log_url = "https://dashboard.heroku.com/apps/#{name}/logs"
  success_box("Your app #{name} is now deployed at #{app_url}! If you encounter any issues, check the logs at #{log_url}.")
  dns_target = get_heroku_dns_target(name, app_url)
  unless dns_target.nil?
    box("NOTE: Since you configured a custom host URL (#{app_url}), you must set your URL's DNS settings to point to #{dns_target} before using the app if you haven't already. You can find more info #{TTY::Link.link_to("here.", "http://url.perlmutterapp.com/custom-url")}")
  end
end

# Adds an arg to set of args if converted properly
def push_arg_if_present(key, arg, state)
  unless arg.nil?
    case state
    when "yml"
      download_path = "config/locales/org/#{key}.yml"
      TTY::File.download_file(arg, download_path)
      @args[key] = YAML.load(File.read(download_path))
      File.delete(download_path) if File.exist?(download_path)
    when "boolean"
      @args[key] = arg.to_s.downcase == "true"
    when "integer"
      @args[key] = arg.to_i
    else
      @args[key] = arg
    end
  end
end

# Configures given args at runtime
def configure_args
  @args = {}
  OptionParser.new do |opt|
    opt.on('-c', '--configure STRING', String) { |arg| push_arg_if_present( "configure", arg, "boolean") }
    opt.on('-d', '--deploy STRING', String) { |arg| push_arg_if_present( "deploy", arg, "boolean") }
    opt.on('-on', '--org_name STRING', String) { |arg| push_arg_if_present( "org_name", arg, "string") }
    opt.on('-od', '--org_desc STRING', String) { |arg| push_arg_if_present( "org_desc", arg, "string") }
    opt.on('-odo', '--org_domain STRING', String) { |arg| push_arg_if_present( "org_domain", arg, "string") }
    opt.on('-oe', '--org_email STRING', String) { |arg| push_arg_if_present( "org_email", arg, "string") }
    opt.on('-op', '--org_phone STRING', String) { |arg| push_arg_if_present( "org_phone", arg, "string") }
    opt.on('-of', '--org_facebook STRING', String) { |arg| push_arg_if_present( "org_facebook", arg, "string") }
    opt.on('-ot', '--org_twitter STRING', String) { |arg| push_arg_if_present( "org_twitter", arg, "string") }
    opt.on('-oi', '--org_instagram STRING', String) { |arg| push_arg_if_present( "org_instagram", arg, "string") }
    opt.on('-ow', '--org_website STRING', String) { |arg| push_arg_if_present( "org_website", arg, "string") }
    opt.on('-cp', '--color_primary STRING', String) { |arg| push_arg_if_present( "color_primary", arg, "string") }
    opt.on('-cs', '--color_secondary STRING', String) { |arg| push_arg_if_present( "color_secondary", arg, "string") }
    opt.on('-l', '--logo STRING', String) { |arg| push_arg_if_present( "logo", arg, "string") }
    opt.on('-lo', '--logo_option STRING', String) { |arg| push_arg_if_present( "logo_option", arg, "string") }
    opt.on('-su', '--smtp_username STRING', String) { |arg| push_arg_if_present( "smtp_username", arg, "string") }
    opt.on('-sp', '--smtp_password STRING', String) { |arg| push_arg_if_present( "smtp_password", arg, "string") }
    opt.on('-sa', '--smtp_address STRING', String) { |arg| push_arg_if_present( "smtp_address", arg, "string") }
    opt.on('-so', '--smtp_port STRING', String) { |arg| push_arg_if_present( "smtp_port", arg, "integer") }
    opt.on('-as', '--account_sid STRING', String) { |arg| push_arg_if_present( "account_sid", arg, "string") }
    opt.on('-at', '--auth_token STRING', String) { |arg| push_arg_if_present( "auth_token", arg, "string") }
    opt.on('-ae', '--admin_email STRING', String) { |arg| push_arg_if_present( "admin_email", arg, "string") }
    opt.on('-ap', '--admin_password STRING', String) { |arg| push_arg_if_present( "admin_password", arg, "string") }
    opt.on('-af', '--admin_first_name STRING', String) { |arg| push_arg_if_present( "admin_first_name", arg, "string") }
    opt.on('-al', '--admin_last_name STRING', String) { |arg| push_arg_if_present( "admin_last_name", arg, "string") }
    opt.on('-hc', '--heroku_command STRING', String) { |arg| push_arg_if_present( "heroku_command", arg, "string") }
    opt.on('-ha', '--heroku_app_name STRING', String) { |arg| push_arg_if_present( "heroku_app_name", arg, "string") }
    opt.on('-sn', '--form_name STRING', String) { |arg| push_arg_if_present( "form_name", arg, "string") }
    opt.on('-f', '--faq STRING', String) { |arg| push_arg_if_present( "faq", arg, "yml") }
    opt.on('-s', '--form STRING', String) { |arg| push_arg_if_present( "form", arg, "yml") }
  end.parse!
end

# Initializes an organization's app, either configuration, deployment, or both
def initialize_organization
  @prompt = TTY::Prompt.new(symbols: {marker: "→"})
  @config = {}
  @config["config"] = {}
  @cmd = TTY::Command.new
  configure_args
  if @args.empty?
    @prompt.keypress(prompt_box("Welcome to the Perlmutter App initialization! This initializer utilizes keyboard input for controls. These could include the arrow keys, full text input, or pressing a single key to continue. Please continue by pressing any key, or by waiting 10 seconds."), timeout: 10)
    if @prompt.keypress(prompt_box("By proceeding, you will configure many services, two paid. Twilio, a phone automation service, to send calls/texts on your behalf, as well as Heroku, a hosting and deployment service, and you acknowledge that charges and account balances are your own responsibility to monitor, and not Perlmutter App nor any of its contributors. Charges only occur based on scale of usage, a full cost outline can be found in the README.  Please acknowledge the terms above. (Y/n)")).downcase == "y"
      case @prompt.select(prompt_box("Please select whether you would like to configure your app, deploy your app, or both."), %W[Configure Deploy Both])
      when "Configure"
        configure_organization
      when "Deploy"
        begin
          yaml = YAML.load(File.open("config/locales/org/config/en.yml", "rb").read)
          @config["config"] = yaml["en"]["config"]
          deploy_organization
        rescue StandardError
          error_box("Failed to begin deploying from your config. Please verify its validity and re-run, and if not, run the configure option and start anew.")
        end
      else
        configure_organization
        deploy_organization
      end
    else
      error_box("Denied agreement, please re-run and accept to proceed.")
    end
  else
    box("Ran with arguments, proceeding to invoke them silently...")
    configure_enabled = get_argument_value("configure", false, false)
    if configure_enabled
      configure_organization
    end
    deploy_enabled = get_argument_value("deploy", false, false)
    if deploy_enabled
      deploy_organization
    end

    if !configure_enabled && !deploy_enabled
      error_box("No initializer option selected, please select configure, deploy, or both via flag.")
    end
  end
end

initialize_organization
