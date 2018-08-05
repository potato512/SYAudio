Pod::Spec.new do |s|
  s.name         = "SYAudio"
  s.version      = "1.2.0"
  s.summary      = "Easy to play or stop audio, and to record the radio."
  s.homepage     = "https://github.com/potato512/SYAudio"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "herman" => "zhangsy757@163.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/potato512/SYAudio.git", :tag => "#{s.version}" }
  s.source_files  = "SYAudio/*.{h,m}", "SYAudio/LameUitls/*.{h,a}"
  s.frameworks   = "AVFoundation", "AudioToolbox", "UIKit", "Foundation"
  s.requires_arc = true
end