NAME_SETUP_TEMPLATE = 'Rails4 Template'
PATH_TEMPLATES = File.join(File.dirname(__FILE__), 'templates')

# Gems
# ==================================================
uncomment_lines 'Gemfile', "gem 'bcrypt'"
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
end

gem_group :test do
  gem 'rspec-rails'
  # gem 'capybara'
  # gem 'capybara-webkit'
  # gem 'launchy'
  # gem 'factory_girl_rails'
  # gem 'database_cleaner'
end

# .bundle
directory(File.join(PATH_TEMPLATES, '.bundle'), '.bundle')
run 'bundle install'
#
[
  '.bowerrc',
  '.dockerignore',
  '.env',
  '.rubocop.yml',
  'app/views/layouts/application.html.slim',
  'bower.json',
  'Dockerfile'
].each do | n |
  template File.join(PATH_TEMPLATES, n), n, {app_name: app_name}
end

# .gitignore
comment_lines '.gitignore', '/.bundle'
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
# app/views/layouts/application.html.erb
run 'rm app/views/layouts/application.html.erb'
# config/environments/development.rb
run "echo 'STDOUT.sync = true' >> config/environments/development.rb"
# Procfile
run "echo 'web: bundle exec rails server -p $PORT' >> Procfile"

run 'bundle exec wheneverize .'
run 'bundle exec guard init rspec'
run 'bin/rails g rspec:install'
# run 'bin/rails g cancan:ability'

# Use sass
run 'mv app/assets/stylesheets/application.css'\
    ' app/assets/stylesheets/application.css.scss'
run "sed -i '' /require_tree/d app/assets/javascripts/application.js"
run "sed -i '' /require_tree/d app/assets/stylesheets/application.css.scss"
# bourbon
run 'echo >> app/assets/stylesheets/application.css.scss'
# run "echo '@import \"bourbon\";' "\
#     " >> app/assets/stylesheets/application.css.scss"

# bower
run 'bower install'

# run 'rails g simple_form:install --bootstrap'

# Rubocop
run 'bundle exec rubocop --auto-gen-config'
run 'bundle exec spring binstub --all'

# Git: Initialize
# ==================================================
git :init
git add: '.'
git commit: %( -m 'Initial commit' )

say_status :end, "#{NAME_SETUP_TEMPLATE} Complete!"
