Pod::Spec.new do |s|
  s.name             = "Google-Analytics-for-OS-X-and-iOS"
  s.version          = "1.1.1"
  s.summary          = "Google Analytics SDK for OS X and iOS"
  s.description      = <<-DESC
  This is an Objective-C wrapper around Google's Measurement Protocol
                       DESC

  s.homepage         = "https://github.com/Splendent/Google-Analytics-for-OS-X"
  s.screenshots     = "http://raw.githubusercontent.com/MacPaw/Google-Analytics-for-OS-X/master/screenshot.png"
  s.license          = 'MIT'
  s.author           = { "Denys Stas" => "zyafa@macpaw.com", "Brandon Wang" => "Matsurika@hotmail.com.tw" }
  s.source           = { :git => "https://github.com/Splendent/Google-Analytics-for-OS-X.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/MacPaw'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true

  s.source_files = "GoogleAnalyticsTracker/*.{h,m,xib}"
  s.osx.source_files = "GoogleAnalyticsTracker/osx/*.{h,m,xib}"
  s.ios.source_files = "GoogleAnalyticsTracker/ios/*.{h,m,xib}"
  s.module_name = "GoogleAnalyticsTracker"
  s.header_dir = "GoogleAnalyticsTracker"
end
