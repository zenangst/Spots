# Live editing

As mentioned above, **Spots** internal view state cache uses JSON for saving the state to disk. To leverage even more from JSON, **Spots** has a built-in feature to live edit what you see on screen. If you compile **Spots** with the `-DDEVMODE` flag, **Spots** will monitor the current cache for any changes applied to the view cache. It will also print the current cache path to the console so that you easily grab the file url, open it in your favorite source code editor to play around your view and have it reload whenever you save the file.

*Live editing only works when running your application in the Simulator.*

If you want to enable live editing for you debug target. Add the following to your Podfile:

```ruby
target 'YOUR TARGET HERE' do
  post_install do |installer|
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
```
