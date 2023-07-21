#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint millimeters.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'millimeters'
  s.version          = '0.0.1'
  s.summary          = 'Determine the screen size in millimeters and size your Widgets to be equally large on every screen.'
  s.description      = <<-DESC
  Determine the screen size in millimeters and size your Widgets to be equally large on every screen.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Bent Hillerkus' => 'bent@bent.party' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
