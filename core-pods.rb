def core_pods
  pod 'Spots', path: '../../'
  pod 'Brick', :git => 'https://github.com/hyperoslo/Brick', :branch => 'swift-3'
  pod 'Tailor', '2.0.1'
  pod 'CryptoSwift', '0.6.0'
  pod 'Cache', :git => 'https://github.com/hyperoslo/Cache', :branch => 'swift-3'

  post_install do |installer|
    puts("Enabling dev mode for Spots")
    Dir.glob(File.join("Pods", "**", "Pods*{debug,Private}.xcconfig")).each do |file|
      File.open(file, 'a') { |f| f.puts "\nDEBUG_INFORMATION_FORMAT = dwarf" }
    end
    installer.pods_project.targets.each do |target|
      if target.name == 'Spots'
        target.build_configurations.each do |config|
          if config.name == 'Debug'
            config.build_settings['OTHER_SWIFT_FLAGS'] = '-DDEBUG -DDEVMODE'
            else
            config.build_settings['OTHER_SWIFT_FLAGS'] = ''
          end
        end
      end
    end
  end
end
