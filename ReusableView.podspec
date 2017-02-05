
Pod::Spec.new do |s|
  s.name         = "ReusableView"
  s.version      = "1.0.0"
  s.summary      = "Reusable and NonReusable viewModel containers"

  s.homepage     = "https://github.com/sinarionn/ReusableView"
  s.license      = "MIT"
  s.author       = { "Artem Antihevich" => "sinarionn@gmail.com" }
  s.social_media_url = 'https://twitter.com/sinarionn'

  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/sinarionn/ReusableView.git", :tag => s.version.to_s }
  s.requires_arc = true
  s.dependency 'RxSwift' , '~> 3.0.0'

  s.source_files = 'Sources/*.swift'  
end
