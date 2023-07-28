# Uncomment the next line to define a global platform for your project
platform :ios, '16.4'

target 'LunchApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for LunchApp
	pod 'Firebase/Analytics'
	pod 'Firebase/Core'
	pod 'Firebase/Auth'
	pod 'Firebase/Firestore'
        pod 'DropDown'

  target 'LunchAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'LunchAppUITests' do
    # Pods for testing
  end

end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.4'               end
          end
   end
end
