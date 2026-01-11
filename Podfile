# eCoffee iOS Application
# Author: Vadym Shukurov

platform :ios, '16.0'

target 'eCoffee' do
  use_frameworks!

  # Firebase SDK - Latest stable versions
  pod 'Firebase/Analytics', '~> 11.0'
  pod 'Firebase/Auth', '~> 11.0'
  pod 'Firebase/Firestore', '~> 11.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
      
      # Silence warnings from pods
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
      
      # Required for Xcode 15+
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
    end
  end
end
