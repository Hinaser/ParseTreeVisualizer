source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0'

gem 'puma'

gem 'sqlite3'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Use HAML for default view files.
gem 'haml-rails'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Per-request global storage for Rack
gem 'request_store'

# Misc of gem files for front end service
gem 'bootstrap-sass'
gem 'bootstrap-social-rails'
gem 'font-awesome-rails'
gem 'famfamfam_flags_rails'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'jquery-ui-rails'
gem 'jquery-datetimepicker-rails'
gem 'jquery-dotdotdot-rails'
gem 'nprogress-rails'
gem 'underscore-rails'
gem 'dropzonejs-rails'
gem 'nicescroll-rails'

# Social share buttons
gem 'social-share-button'

# Share variables between ruby on server and javascript on client.
gem 'gon'

# Keyboard shortcuts
gem 'mousetrap-rails'

# Settings
gem 'settingslogic'

# Database
gem 'default_value_for'
gem 'enumerize'

# Protect against bruteforcing
gem 'rack-attack'

# URI parser
gem 'addressable'

# HTML parser
# See https://groups.google.com/forum/#!topic/ruby-security-ann/aSbgDiwb24s
# and https://groups.google.com/forum/#!topic/ruby-security-ann/Dy7YiKb_pMM
gem 'nokogiri', '~> 1.6.7', '>= 1.6.7.2'

gem 'charlock_holmes'
gem 'ruby-filemagic'

gem 'browser'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'awesome_print'
  gem 'fuubar'
  gem 'pry-rails'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'rubocop', require: false

  # Better errors handler
  gem 'better_errors'
  gem 'binding_of_caller'

  # Generate Fake data
  gem 'ffaker'

  # Prevent occasions where minitest is not bundled in packaged versions of ruby (see #3826)
  gem 'minitest'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Use Capistrano for deployment
  gem 'capistrano-rails'

  # thin instead webrick
  gem 'thin'

  # Colored output to console
  gem 'colored'

  gem 'annotate'
  gem 'letter_opener'
  gem 'letter_opener_web', '~> 1.2.0'
end

group :test do
  gem 'simplecov', require: false
  gem 'shoulda-matchers', require: false
  gem 'email_spec'
  gem 'webmock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'coffee-script-source', '1.8.0'
