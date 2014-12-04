if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1
fi

if [ -z "$1" ]
  then
    echo "No argument supplied"
    exit 1
fi

ROOTDIR="$1"
echo $ROOTDIR

if [ ! -d "$ROOTDIR" ]; then
  echo "$ROOTDIR is not a directory"
  exit 1
fi

cd $ROOTDIR
FILE=Gemfile

if [ -f $FILE ];
then
   echo "File $FILE exists."
else
   echo "File $FILE does not exist."
   exit 1
fi

echo 'installing rspec to $rootdir'
echo "#testing" >> Gemfile
echo "gem 'rspec-rails', '~> 3.0', :group => [:test, :development] >> Gemfile"
echo "gem 'rspec-rails', '~> 3.0', :group => [:test, :development]" >> Gemfile
echo "gem 'rspec_junit_formatter', :group => [:test, :development] >> Gemfile"
echo "gem 'rspec_junit_formatter', :group => [:test, :development]" >> Gemfile
echo "gem 'factory_girl_rails', :group => [:test, :development] >> Gemfile"
echo "gem 'factory_girl_rails', :group => [:test, :development]" >> Gemfile
echo "gem 'shoulda-matchers', require: false, :group => [:test, :development] >> Gemfile"
echo "gem 'shoulda-matchers', require: false, :group => [:test, :development]" >> Gemfile

echo "bundle install --without production"
bundle install --without production

echo "rails generate rspec:install"
rails generate rspec:install

echo "require 'shoulda/matchers' to spec/rails_helper.rb"
sed -i "s,require 'rspec/rails',require 'rspec/rails'\nrequire 'shoulda/matchers'," spec/rails_helper.rb

tee -a .rspec <<EOF
--format RspecJunitFormatter
--out test-reports/rspec.xml
EOF
echo "/test-reports" >> .gitignore


echo 'installing cucumber to $rootdir'

echo 'updating Gemfile'
tee -a Gemfile <<EOF
gem 'cucumber-rails', :require => false, :group => [:test, :development]
gem 'database_cleaner', :group => [:test, :development]
gem 'capybara-webkit', '~> 1.3.0', :group => [:test, :development]
gem 'headless', :group => [:test, :development]
EOF

echo "bundle install --without production"
bundle install --without production

echo "rails generate cucumber:install"
rails generate cucumber:install

echo 'add World FactoryGirl::Syntax::Methods to features/support/env.rb'
tee -a features/support/env.rb <<EOF
World FactoryGirl::Syntax::Methods
EOF


echo 'add webkit,headless and capybara to features/support/env.rb'
tee -a features/support/env.rb <<EOF
Capybara.app = Rack::ShowExceptions.new(Rails.application)
# use webkit driver for javascript testing
Capybara.javascript_driver = :webkit
if Capybara.javascript_driver == :webkit
  require 'headless'
  headless = Headless.new
  headless.start
end
EOF

echo 'installing simplecov to $rootdir'

echo 'updating Gemfile'
tee -a Gemfile <<EOF
gem 'simplecov', :require => false, :group => :test
EOF

echo "bundle install --without production"
bundle install --without production

echo "require 'simplecov' at the top of spec/rails_helper.rb"
sed -i "1s,^,require 'simplecov'\nSimpleCov.command_name 'RSpec'\n," spec/rails_helper.rb

echo "require 'simplecov' at the top of features/support/env.rb"
sed -i "1s,^,require 'simplecov'\nSimpleCov.command_name 'Cucumber'\n," features/support/env.rb

tee -a .simplecov <<EOF
SimpleCov.start 'rails' do
end
EOF

echo "gitignore /coverage"
echo "/coverage" >> .gitignore

