Pod::Spec.new do |s|
    s.name         = 'SwipabelCell'
    s.version      = '0.1.0'
    s.summary      = 'Swipable cell, support UITableView and ASTableView from Texture'
    s.homepage     = 'https://github.com/ChaselAn/SwipableCell'
    s.license      = 'MIT'
    s.authors      = {'ChaselAn' => '865770853@qq.com'}
    s.platform     = :ios, '9.0'
    s.source       = {:git => 'https://github.com/ChaselAn/SwipableCell.git', :tag => s.version}
    s.source_files = 'EditTableViewCell/SwipableCell/*.swift'
    s.requires_arc = true
    s.dependency 'Texture', '~> 2.6'
end
