#
# Be sure to run `pod lib lint RESTful.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RESTful'
  s.version          = '4.0.0-beta.2-v1'
  s.summary          = 'RESTful is a small but powerful library that makes creating REST clients simple and fun.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
						RESTful is a small but powerful library that makes creating REST clients simple and fun.
                       DESC

  s.homepage         = 'https://github.com/tospery/RESTful'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tospery' => 'tospery@gmail.com' }
  s.source           = { :git => 'https://github.com/tospery/RESTful.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'RESTful/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RESTful' => ['RESTful/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'ReactiveObjC', '3.1.1'
  s.dependency 'AFNetworking', '3.2.1'
  s.dependency 'Mantle', '2.1.1'
end
