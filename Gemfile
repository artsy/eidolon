source 'https://rubygems.org'

gem 'cocoapods'
# So we know if we need to run `pod install`
gem 'cocoapods-check'
gem 'cocoapods-keys'

gem 'sbconstants', '< 1.2.0'
gem 'second_curtain'
gem 'fastlane'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
