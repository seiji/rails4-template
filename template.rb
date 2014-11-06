# Gems
# ==================================================
uncomment_lines 'Gemfile', "gem 'bcrypt'"
uncomment_lines 'Gemfile', "gem 'capistrano-rails'"
uncomment_lines 'Gemfile', "gem 'therubyracer'"
uncomment_lines 'Gemfile', "gem 'unicorn'"

# gem 'analytics-ruby'
# gem 'bourbon'
# gem 'cancan'
gem 'slim-rails'

# gem 'simple_form', git: 'https://github.com/plataformatec/simple_form'
# gem 'uuidtools'

gem 'whenever', require: false

gem_group :development do
  gem 'rubocop'
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-ext'
end

gem_group :test do
  gem 'rspec-rails'
  # gem 'capybara'
  # gem 'capybara-webkit'
  # gem 'launchy'
  # gem 'factory_girl_rails'
  # gem 'database_cleaner'
end

# .bundle/config
run 'mkdir .bundle'
file '.bundle/config', <<-CODE
---
BUNDLE_PATH: .bundle/gems
BUNDLE_DISABLE_SHARED_GEMS: '1'
BUNDLE_BIN: .bundle/bin
CODE
run 'bundle install'

# .bowerrc
file '.bowerrc', <<-CODE
{
  "directory": "vendor/assets/bower_components"
}
CODE
# .env
run 'echo PORT=3000 >> .env'

comment_lines '.gitignore', '/.bundle'
# .gitignore
run "cat << EOF >> .gitignore
*.swp
.bundle/bin
.bundle/gems
.env
.project
.secret
.vagrant
.DS_Store

database.yml
doc/
/vendor/assets/bower_components

EOF"

# app/view/layouts/application.html.slim
file 'app/views/layouts/application.html.slim', <<-CODE
doctype html
html
  head
    title #{app_name}
= stylesheet_link_tag "application", media:"all","data-turbolinks-track" => true
= javascript_include_tag "application", "data-turbolinks-track" => true
= csrf_meta_tags

body
  = yield
CODE
run 'rm app/views/layouts/application.html.erb'
# config/environments/development.rb
run "echo 'STDOUT.sync = true' >> config/environments/development.rb"
# Procfile
run "echo 'web: bundle exec rails server -p $PORT' >> Procfile"

run 'bundle exec cap install'
run 'bundle exec wheneverize .'
# lib/capistrano/tasks/whenever.rake
file 'lib/capistrano/tasks/whenever.rake', <<-CODE
require 'whenever/capistrano'
set :whenever_identifier, -> { "\#{fetch(:application)}_\#{fetch(:stage)}" }
CODE

run 'bundle exec guard init rspec'
# run 'bin/rails g cancan:ability'

# Use sass
run 'mv app/assets/stylesheets/application.css'\
    ' app/assets/stylesheets/application.css.scss'
run "sed -i '' /require_tree/d app/assets/javascripts/application.js"
run "sed -i '' /require_tree/d app/assets/stylesheets/application.css.scss"
# bourbon
run 'echo >> app/assets/stylesheets/application.css.scss'
run "echo '@import \"bourbon\";' >> app/assets/stylesheets/application.css.scss"

# bower
run 'bower init'
run 'bower install jquery bootstrap font-awesome --save'

# run 'rails g simple_form:install --bootstrap'

# Rubocop
run 'bundle exec rubocop --auto-gen-config'
file '.rubocop.yml', <<-CODE
inherit_from: .rubocop_todo.yml
CODE

# Git: Initialize
# ==================================================
git :init
git add: '.'
git commit: %( -m 'Initial commit' )
