Pod::Spec.new do |s|
  s.name         = "NCMB"
  s.version      = "0.1.0"
  s.summary      = "NCMB is SDK for NIFCLOUD mobile backend."
  s.description  = <<-DESC
                   NCMB is SDK for NIFCLOUD mobile backend.
                   NIF Cloud mobile backend function
                   * Data store
                   * Push Notification
                   * User Management
                   * SNS integration
                   * File store
                   DESC
  s.homepage     = "https://mbaas.nifcloud.com"
  s.license      = "Apache License, Version 2.0"
  s.author       = "FUJITSU CLOUD TECHNOLOGIES LIMITED"
  s.platform     = :ios, "10.0"
  s.source       = { :git => 'https://github.com/NIFCloud-mbaas/ncmb_ios.git', :tag => "v#{s.version}" }
  s.source_files  = "NCMB/**/*.{swift}"
  s.frameworks = "Foundation", "UIKit", "MobileCoreServices", "AudioToolbox", "SystemConfiguration"
  s.requires_arc = true
end
