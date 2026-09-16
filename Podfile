platform :ios, '17.0'

target 'todoList' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for todoList
  pod 'FSCalendar'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  
  target 'todoListTests' do
    # Pods for testing
    pod 'RxTest'
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    end
  end
end
