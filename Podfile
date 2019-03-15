project 'Borken Playgrounds.xcodeproj'

# Uncomment the next line to define a global platform for your project
platform :ios, '12.1'

target 'Borken Playgrounds' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for Borken Playgrounds
  pod 'ImageSlideshow'
  pod 'Firebase/Firestore'
  pod 'Firebase/Core'
  pod 'Firebase/RemoteConfig'
  pod 'Kingfisher'
  pod 'Mapbox-iOS-SDK'
  pod 'SPPermission'
  pod "ImageSlideshow/Kingfisher"
  pod "KingfisherWebP"
  pod "SkeletonView"
  pod 'SnapKit'
  pod 'SparrowKit'
  pod 'QuickTableViewController'
  pod 'Carte'
  
  target 'Borken PlaygroundsTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Borken PlaygroundsUITests' do
    inherit! :search_paths
    # Pods for testing
  end
    
end

post_install do |installer|
      pods_dir = File.dirname(installer.pods_project.path)
      at_exit { `ruby #{pods_dir}/Carte/Sources/Carte/carte.rb configure` }
end
