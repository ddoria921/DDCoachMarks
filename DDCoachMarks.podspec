Pod::Spec.new do |s|
  s.name         = "DDCoachMarks"
  s.version      = "1.0.0"
  s.summary      = "Quick and easy coach marks to use in any iOS app."
  s.homepage     = "https://github.com/ddoria921/DDCoachMarks"
  s.license      = 'MIT'
  s.author       = { "Darin Doria" => "ddoria921@gmail.com" }
  s.source       = { :git => "https://github.com/ddoria921/DDCoachMarks.git", :branch => "master" }
  s.platform     = :ios, '6.0'
  s.source_files = 'Coach Marks/DD*.{h,m}'
  s.frameworks   = 'Foundation', 'UIKit', 'QuartzCore'
  s.requires_arc = true
end
