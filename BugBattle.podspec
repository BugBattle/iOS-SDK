Pod::Spec.new do |s|
  s.name         = "BugBattle"
  s.version      = "0.0.1"
  s.summary      = "In-App Bug Reporting and Testing for Apps. Learn more at https://www.bugbattle.app"
  s.homepage     = "https://www.bugbattle.app"
  s.license      = { :type => 'Commercial', :file => 'LICENSE.md' }
  s.author       = { "BugBattle" => "hello@bugbattle.app" }
  s.platform     = :ios, '9.0'
  s.source       = { :git => "https://github.com/BugBattle/BugBattle-iOS-SDK.git", :tag => s.version.to_s }
  s.library      = 'z'
  s.frameworks   = 'UIKit', 'Foundation'
  s.xcconfig     =  { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/BugBattle/"' }
  s.requires_arc = true
  s.source_files = 'BugBattle.framework/Headers/*.{h}'
  s.vendored_frameworks = 'BugBattle.framework'
  s.preserve_paths =  'BugBattle.framework/*'
end