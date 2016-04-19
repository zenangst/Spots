Pod::Spec.new do |s|
  s.name             = "Spots"
  s.summary          = "Spots is a view controller framework that makes your setup and future development blazingly fast."
  s.version          = "1.1.4"
  s.homepage         = "https://github.com/hyperoslo/Spots"
  s.license          = 'MIT'
  s.author           = { "Hyper Interaktiv AS" => "ios@hyper.no" }
  s.source           = { :git => "https://github.com/hyperoslo/Spots.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/hyperoslo'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'

  s.requires_arc = true
  s.ios.source_files = 'Sources/{iOS,Shared}/**/*'
  s.osx.source_files = 'Sources/{Shared}/**/*'

  s.frameworks = 'Foundation'
  s.dependency 'Sugar'
  s.dependency 'Tailor'
  s.dependency 'Brick'
end
