Pod::Spec.new do |s|
  s.name = "Rideau"
  s.version = '1.0.0-rc.2'
  s.swift_version = "5.0"
  s.summary = "A vertical drawer with fluid user interface."

  s.homepage = "https://github.com/muukii/Rideau"
  s.license = 'MIT'
  s.authors = {
    "Muukii" => "muukii.app@gmail.com"
  }
  s.source = { :git => "https://github.com/muukii/Rideau.git", :tag => s.version }

  s.social_media_url = 'https://twitter.com/muukii_app'
  s.source_files = ['Rideau/**/*.{swift,h}']
  s.public_header_files = 'Rideau/**/*.h'

  s.module_name = s.name
  s.requires_arc = true
  s.ios.deployment_target = '10.0'
  s.ios.frameworks = ['Foundation', 'UIKit']
end
