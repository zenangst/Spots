Pod::Spec.new do |s|
  s.name             = "Spots"
  s.summary          = "A short description of Spots."
  s.version          = "0.1.0"
  s.homepage         = "https://github.com/hyperoslo/Spots"
  s.license          = 'MIT'
  s.author           = { "Hyper Interaktiv AS" => "ios@hyper.no" }
  s.source           = { :git => "https://github.com/hyperoslo/Spots.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/hyperoslo'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Source/**/*'
  s.dependency 'Sugar'
  s.dependency 'Tailor'
  s.dependency 'Imaginry'
end
