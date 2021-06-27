Autoproj.manifest.each_autobuild_package do |pkg|
    next if !pkg.kind_of?(Autobuild::Orogen)
    pkg.depends_on 'tools/rtt_ros_transport'

    # Ensure that CMAKE_PREFIX_PATH is set so that catkin can find packages in a
    # subfolder, share/<pkg_name>_msgs/cmake
    File.mkdir_p pkg.prefix unless File.exist?(pkg.prefix)
    pkg.define 'CMAKE_PREFIX_PATH', "#{Autoproj.user_config("ROS_PREFIX")};#{pkg.prefix}"
end

