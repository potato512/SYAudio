Pod::Spec.new do |s|

  s.name         = "SYAudio.podspec"
  s.version      = "1.0.0"
  s.summary      = "Easy to play or stop audio, and to record the radio."
  s.homepage     = "https://github.com/potato512/SYAudio"
  s.license      = "MIT"
  s.author       = { "herman" => "zhangsy757@163.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/potato512/SYAudio.git", :tag => "#{s.version}" }
  s.source_files  = "SYAudio/AudioRecorderImage/*.{png}", "SYAudio/*.{h,m}"

  s.frameworks = "AVFoundation.framework", "AudioToolbox.framework"
  s.requires_arc = true

end
