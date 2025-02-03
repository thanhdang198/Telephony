Pod::Spec.new do |s|
  s.name             = 'another_telephony'
  s.version          = '0.0.1'
  s.summary          = 'A dummy Flutter plugin.'
  s.description      = <<-DESC
This is a dummy Flutter plugin that does nothing.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Dummy Developer' => 'dummy@example.com' }
  s.source           = { :path => '.' }

  # Ensure it is recognized as a Flutter plugin
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
