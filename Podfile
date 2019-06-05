# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MorseCode' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MorseCode
  pod 'BluetoothKit'
  pod 'SVProgressHUD'
  pod 'SnapKit'
  
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          if ['BluetoothKit', 'MobilePlayer'].include? target.name
              target.build_configurations.each do |config|
                  config.build_settings['SWIFT_VERSION'] = '3.3'
              end
          end
      end
  end
  
end
