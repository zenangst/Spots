Pod::Spec.new do |s|
  s.name             = "Spots"
  s.summary          = "A cross-platform view controller framework for building component-based UIs"
  s.version          = "5.5.4"
  s.homepage         = "https://github.com/hyperoslo/Spots"
  s.license          = 'MIT'
  s.author           = { "Hyper Interaktiv AS" => "ios@hyper.no" }
  s.source           = { :git => "https://github.com/hyperoslo/Spots.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/hyperoslo'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.2'

  s.requires_arc = true
  s.ios.source_files = 'Sources/{iOS,Shared}/**/*'
  s.osx.source_files = 'Sources/{Mac,Shared}/**/*'
  s.tvos.source_files = 'Sources/{iOS,tvOS,Shared}/**/*'

  s.frameworks = 'Foundation'
  s.dependency 'Tailor', '~> 2.0'
  s.dependency 'Brick', '~> 2.0'
  s.dependency 'Cache', '~> 2.0'
  s.dependency 'CryptoSwift', '0.6.0'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }
end
