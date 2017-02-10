Pod::Spec.new do |s|
s.name         = 'WCountingLabel'
s.summary      = 'a counting label framework for iOS.'
s.version      = '0.0.1'
s.license      = { :type => 'MIT', :file => 'LICENSE' }
s.authors      = { 'winter' => '1581221002@qq.com' }
s.homepage     = 'http://git.oschina.net/winter7/WCountingLabel'

s.ios.deployment_target = '7.0'

s.source       = { :git => 'https://git.oschina.net/winter7/WCountingLabel.git', :tag => s.version }

s.requires_arc = true
s.source_files = 'WCountingLabel/*.{h,m}'
s.public_header_files = 'WCountingLabel/WCountingLabel.h'

s.frameworks = 'Foundation', 'QuartzCore'
end
