#
# Be sure to run `pod lib lint BugBattle.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name         = "BugBattle"
  s.version      = "4.1.1"
  s.summary      = "In-App Bug Reporting and Testing for Apps. Learn more at https://www.bugbattle.io"
  s.homepage     = "https://www.bugbattle.io"
  s.license      = { :type => 'Commercial', :file => 'LICENSE.md' }
  s.author       = { "BugBattle" => "hello@bugbattle.io" }

  s.platform     = :ios, '9.0'
  s.source       = { :git => "https://github.com/BugBattle/iOS-SDK.git", :tag => s.version.to_s }
  
  s.source_files = 'BugBattle/Classes/**/*'
  s.public_header_files = 'BugBattle/Classes/**/*.h'
  s.resources = ['BugBattle/Assets/**/*.storyboard', 'BugBattle/Assets/**/*.png']
  
  s.frameworks   = 'UIKit', 'Foundation'
end
