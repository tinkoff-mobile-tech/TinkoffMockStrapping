Pod::Spec.new do |s|
    
  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  s.name     = 'TinkoffMockStrapping'
  s.summary  = 'Library for unifying the approach to network mocking in unit- & UI-tests.'
  s.version  = '0.1.0'
  s.homepage = 'https://github.com/tinkoff-mobile-tech/TinkoffMockStrapping'
  
  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license  = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author   = { 'RomanGL' => 'r.gladkikh@tinkoff.ru',
                 'volokhin' =>  'volokhin@bk.ru',
                 'niceta' => 'n.kuznetsov@tinkoff.ru',
                 'ra2ra' => 'v.rudnevskiy@tinkoff.ru' }

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  s.source   = { :git => 'https://github.com/tinkoff-mobile-tech/TinkoffMockStrapping.git',
                 :tag => s.version.to_s }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  s.default_subspec = 'Core'
  
  # The core subspec without decorators for any type of tests.
  s.subspec 'Core' do |core_spec|
    core_spec.source_files = 'Development/Source/Core/**/*.{swift}'
    
    core_spec.dependency 'SwiftyJSON', '~> 5.0.0'
  end

  # The subspec for UI tests. Swifter (https://github.com/httpswift/swifter) was used as a default mock server.
  s.subspec 'Swifter' do |swifter_spec|
    swifter_spec.source_files = 'Development/Source/Swifter/**/*.{swift}'
    
    swifter_spec.dependency 'TinkoffMockStrapping/Core'
    swifter_spec.dependency 'Swifter', '~> 1.5.0'
  end
  
end
