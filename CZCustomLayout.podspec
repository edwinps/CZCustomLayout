Pod::Spec.new do |s|
    s.name         = 'CZCustomLayout'
    s.version      = '1.1.0'
    s.summary      = 'Library with a custom layout for UICollectionView like pinterest style with a big item at first'
    s.author =
    {
        'Edwin Peña' => 'ejps86@gmail.com'
    }
    s.platform = :ios
    s.source  = {
        :git => "https://github.com/edwinps/CZCustomLayout.git", :tag => "1.1.0"
    }
    
    s.source_files  = "src/**/*.{swift}"
    s.framework  = "Foundation", "UIKit"
    s.ios.deployment_target = '9.0'
    s.homepage     = "https://github.com/edwinps/CZCustomLayout"
    s.license = { :type => 'MIT', :file => 'LICENSE.md' }
end