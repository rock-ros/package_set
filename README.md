# Rock-ROS Package Set

WARNING: This package set is deprecated. There is no need to use this package set in Rock installations anymore, since ROS support is now inbuild.

# Alternative (via inbuilt support)

If case you want to you ROS with Rock please note the following:

Currently the compilation is a bit picky with paths, so:

## For autoproj update
source autoprojs env.sh last:

```
/opt/ros_workspace/devel/setup.sh
source ./env.sh
aup
```

## For building source ROSs setup.sh last:

```
source /opt/ros/melodic/setup.sh
source ./env.sh
source /opt/ros/melodic/setup.sh
amake
```

## For execution, source autoprojs env.sh last:
```
source /opt/ros/melodic/setup.sh
cd /opt/rock_workspace
source env.sh

## Important
 When your first build attempt was without having 
/opt/ros/melodic/setup.sh sourced, the workspace has to be rebuild in 
order to activate the bridge (availability of ROS is cached and not 
updated in CMakeFiles)
