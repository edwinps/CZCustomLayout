Pod::Spec.new do |s|
    s.name         = 'CZCustomLayout'
    s.version      = '2.0.0'
    s.summary      = 'Library with a custom layout for UICollectionView like pinterest style with a big item at first'
    s.author =
    {
        'Edwin Peña' => 'ejps86@gmail.com'
    }
    s.platform = :ios
    s.source  = {
        :git => "https://github.com/edwinps/CZCustomLayout.git", :tag => "2.0.0"
    }
    
    s.source_files  = "src/**/*.{swift}"
    s.framework  = "Foundation", "UIKit"
    s.ios.deployment_target = '10.0'
    s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }
    s.homepage     = "https://github.com/edwinps/CZCustomLayout"
    s.license = { :type => 'MIT', :file => 'LICENSE.md' }
    s.swift_version = '4.2'
end
