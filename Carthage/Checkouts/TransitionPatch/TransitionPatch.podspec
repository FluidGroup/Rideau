Pod::Spec.new do |s|
    s.name         = "TransitionPatch"
    s.version      = "1.0.0"
    s.summary      = "A micro framework to calculate value for transition."
    s.description  = <<-DESC
    A micro-framework to calculate a value for the transition.
    Can define converting value flow declaratively.
                     DESC
    s.license      = "MIT"
    s.author             = { "Muukii" => "muukii.app@gmail.com  " }
    s.social_media_url   = "http://twitter.com/muukii_app"
    s.ios.deployment_target = '8.0'
    s.osx.deployment_target = '10.13'
    s.source       = { :git => "https://github.com/muukii/TransitionPatch.git", :tag => s.version }
    s.source_files  = "TransitionPatch/*.swift"
    s.homepage     = "https://github.com/muukii/TransitionPatch"
  
    s.frameworks = ['Foundation']
  end
  