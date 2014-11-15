SETUP_TEMPLATE_NAME = 'Rails4 Api Template'
# Gems
# ==================================================
uncomment_lines 'Gemfile', "gem 'bcrypt'"
uncomment_lines 'Gemfile', "gem 'capistrano-rails'"
uncomment_lines 'Gemfile', "gem 'therubyracer'"
uncomment_lines 'Gemfile', "gem 'unicorn'"

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

# .env
file '.env',  <<-CODE
PORT=3000
CODE

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

EOF"

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
run 'bin/rails g rspec:install'
# run 'bin/rails g cancan:ability'

# Rubocop
run 'bundle exec rubocop --auto-gen-config'
file '.rubocop.yml', <<-CODE
inherit_from: .rubocop_todo.yml
CODE

run 'bundle exec spring binstub --all'

# Git: Initialize
# ==================================================
git :init
git add: '.'
git commit: %( -m 'Initial commit' )

say_status :end, "#{SETUP_TEMPLATE_NAME} Complete!"
