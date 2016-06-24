
Pod::Spec.new do |s|
s.name             = 'JMCiBeaconManager'
s.version          = '0.1.0'
s.summary          = 'An iBeacon Manager class is responsible for detecting and simulating beacons nearby.'

s.description      = 'An iBeacon Manager class is responsible for detecting and simulating beacons nearby. With RadarView.'

s.homepage         = 'https://github.com/appzzman/JMCBeaconManager.git'
# s.screenshots     = 'https://github.com/appzzman/JMCBeaconManager/blob/pr/1/iPadGif.gif', 'https://raw.githubusercontent.com/appzzman/JMCBeaconManager/pr/1/iPhoneGif.gif'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'FelipeNBrito' => 'felipenevesbrito@gmail.com' }
s.source           = { :git => 'https://github.com/appzzman/JMCBeaconManager.git', :tag => s.version.to_s}

s.ios.deployment_target = '8.0'

s.source_files = 'JMCiBeaconManager/Classes/**/*'

# s.resource_bundles = {
#   'JMCiBeaconManager' => ['JMCiBeac/Users/felipe/Documents/JMCBeaconManager/iBeaconManager/iBeaconManager/ViewController.swiftonManager/Assets/*.png']
# }

# s.public_header_files = 'Pod/Classes/**/*.h'
# s.frameworks = 'UIKit', 'MapKit'
# s.dependency 'AFNetworking', '~> 2.3'
end
