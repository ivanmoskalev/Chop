Pod::Spec.new do |s|
  s.name             = "Chop"
  s.version          = "0.4.0"
  s.summary          = "Future / PackagedTask on steroids. Typesafe abstraction over lazy, composable async operations."
  s.description      = <<-DESC
                        Chop is a delightful framework that provides a simple and expressive way to manage async operations.
                       DESC

  s.homepage         = "https://github.com/ivanmoskalev/Chop"
  s.license          = 'MIT'
  s.author           = { "Ivan Moskalev" => "iv.s.moskalev@gmail.com" }
  s.source           = { :git => "https://github.com/ivanmoskalev/Chop.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ivanmoskalev'

  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'lib/*.swift'
  s.frameworks = 'Foundation'
end
