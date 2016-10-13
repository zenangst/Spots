def core_pods
  pod 'Spots', path: '../../'
  pod 'Brick'
  pod 'Tailor'
  pod 'CryptoSwift', '0.6.0'
  pod 'Cache'

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
