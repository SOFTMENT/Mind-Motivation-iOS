# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Mind Motivations' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Mind Motivations
  pod 'Firebase/Firestore'

   pod 'Firebase/Analytics'
   
   pod 'Firebase/Auth'

   pod 'Firebase/Storage'
   
   pod 'Firebase/Messaging'

   pod 'FirebaseFirestoreSwift'

   pod 'GoogleSignIn'
   
   pod 'MBProgressHUD', '~> 1.2.0'
   
   pod 'SDWebImage', '~> 4.0'

  pod 'CropViewController'
  
  pod 'IQKeyboardManagerSwift'

 pod 'TTGSnackbar'

 pod 'lottie-ios'
 
 pod 'RevenueCat'

 pod 'FBSDKLoginKit'


 
end


post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.2'
          xcconfig_path = config.base_configuration_reference.real_path
          xcconfig = File.read(xcconfig_path)
          xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
          File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
          end
      end
  end
