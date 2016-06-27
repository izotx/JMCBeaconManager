
Pod::Spec.new do |s|
s.name             = 'JMCiBeaconManager'
s.version          = '1.0.1'
s.summary          = 'An iBeacon Manager class is responsible for detecting and simulating beacons nearby.'

s.description      = 'An iBeacon Manager class is responsible for detecting and simulating beacons nearby. With RadarView.'

s.homepage         = 'https://github.com/izotx/JMCBeaconManager.git'
# s.screenshots     = 'https://https://github.com/izotx/JMCBeaconManager/blob/pr/1/iPadGif.gif', 'https://raw.githubusercontent.com/appzzman/JMCBeaconManager/pr/1/iPhoneGif.gif'
s.license          = { :type => 'BSD', :file => 'LICENSE' }
s.authors           = {'Janusz Chudzynski' => 'jchudzynski@uwf.edu', 'Felipe N. Brito' => 'felipenevesbrito@gmail.com'}
s.source           = { :git => 'https://github.com/izotx/JMCBeaconManager.git', :tag => s.version.to_s}

s.ios.deployment_target = '8.0'

s.source_files = 'JMCiBeaconManager/Classes/**/*'
end
