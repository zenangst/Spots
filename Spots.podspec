Pod::Spec.new do |s|
  s.name             = "Spots"
  s.summary          = "A cross-platform view controller framework for building component-based UIs"
  s.version          = "7.5.0"
  s.homepage         = "https://github.com/hyperoslo/Spots"
  s.license          = 'MIT'
  s.author           = { "Hyper Interaktiv AS" => "ios@hyper.no" }
  s.source           = { :git => "https://github.com/hyperoslo/Spots.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/hyperoslo'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.2'

  s.requires_arc = true

  s.ios.source_files = 'Sources/{Universal,iOS,iOS+tvOS}/**/*'
  s.osx.source_files = 'Sources/{Universal,macOS}/**/*'
  s.tvos.source_files = 'Sources/{Universal,tvOS,iOS+tvOS}/**/*'
  
  s.dependency 'Cache', '~> 4.0'
  s.framework  = "Foundation"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
end
