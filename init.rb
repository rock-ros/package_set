available_ros_versions = []
Dir.glob('/opt/ros/*') do |path|
    if path >= '/opt/ros/g'
        available_ros_versions << path
    end
end

configuration_option('ROS_PREFIX', 'string',
    :default => available_ros_versions.max,
    :doc => ["Which ROS prefix should we be using ? (needs to be groovy or newer)"]) do |path|
    path = File.expand_path(path)
    if !File.directory?(path)
        raise Autoproj::InputError, "#{path} does not exist or is not a directory"
    elsif !File.directory?(cmake_path = File.join(path, 'share', 'catkin', 'cmake'))
        raise Autoproj::InputError, "#{path} does not look like a ROS install path (#{cmake_path} does not exist)"
    end
    path
end

Autobuild.update_environment Autoproj.user_config('ROS_PREFIX')
Autoproj.env_add_path 'CMAKE_PREFIX_PATH', Autoproj.user_config('ROS_PREFIX')
Autoproj.env_set 'ROS_SETUP', Autoproj.user_config('ROS_PREFIX') + "/setup.sh"
Autoproj.env_add_path 'PYTHONPATH', File.join(Autoproj.user_config('ROS_PREFIX'), 'lib', 'python2.7', 'dist-packages')
Autoproj.env_set 'ROS_MASTER_URI', 'http://localhost:11311'
Autobuild.env_clear 'ROS_ROOT'

Autobuild::Orogen.transports << 'ros'
Autoproj.workspace.osdep_suffixes << "ros-#{Autoproj.config.get('ROS_PREFIX')}"

# We cannot set ROS_ROOT within the autoproj environment as some of the RTT
# stuff still tries to build as ROS when set. Instead, set ROS_ROOT in a
# separate env file and source it at the end of the env.sh
env_ros = File.join(Autoproj.root_dir, ".env-ros.sh")
File.open(env_ros, 'w') do |io|
    io.puts "export ROS_ROOT=#{Autoproj.user_config('ROS_PREFIX')}"
end
Autoproj.env_source_after env_ros
