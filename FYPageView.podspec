Pod::Spec.new do |spec|

  spec.name         = "FYPageView"

  spec.version      = "1.0.0"

  spec.summary      = "A pageView used on iOS."

  spec.description  = <<-DESC
                         It is a pageView used on iOS, which implement by Swift.
                   DESC

  spec.homepage     = "https://github.com/freeisnice/FYPageView"

  spec.license      = "MIT"

  spec.author             = { "sven" => "2776369342@qq.com" }

  spec.swift_version = '5.0'
  
  spec.platform     = :ios, "10.0"

  spec.source       = { :git => "https://github.com/freeisnice/FYPageView.git", :tag => spec.version.to_s }

  spec.source_files  = "FYPageView/*"

  spec.framework  = "UIKit"

  spec.requires_arc = true
end
