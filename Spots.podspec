Pod::Spec.new do |s|
  s.name             = "Spots"
  s.summary          = "A cross-platform view controller framework for building component-based UIs"
  s.version          = "6.0.0"
  s.homepage         = "https://github.com/hyperoslo/Spots"
  s.license          = 'MIT'
  s.author           = { "Hyper Interaktiv AS" => "ios@hyper.no" }
  s.source           = { :git => "https://github.com/hyperoslo/Spots.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/hyperoslo'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.2'

  s.requires_arc = true
  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.ios.source_files = 'Sources/{iOS,Shared}/**/*'
    ss.osx.source_files = 'Sources/{macOS,Shared}/**/*'
    ss.tvos.source_files = 'Sources/{iOS,tvOS,Shared}/**/*'
    ss.dependency 'Tailor', '~> 2.0'
    ss.dependency 'Cache', '~> 2.0'
    ss.dependency 'CryptoSwift', '0.6.0'
    ss.framework  = "Foundation"
  end

  s.subspec "RxSwift" do |ss|
    ss.source_files = "RxSpots/**/*"
    ss.dependency "Spots/Core"
    ss.dependency "RxCocoa", "~> 3.2.0"
  end

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }
end
