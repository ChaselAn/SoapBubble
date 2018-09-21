# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

target 'EditTableViewCell' do
  pod 'Texture'

end

target 'SoapBubble' do
    pod 'Texture'
end

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        if target.name == "Texture" then
            target.build_configurations.each do |configuration|
                if configuration.name.include?("Debug") then
                    configuration.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
                end
            end
        end
    end
end
