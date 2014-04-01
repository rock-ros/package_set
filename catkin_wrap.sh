#!/bin/sh
cd ${AUTOPROJ_PROJECT_BASE}
unset PKG_CONFIG_PATH
unset LD_LIBRARY_PATH
. ${ROS_SETUP}
cd ros
export LANG=C
catkin_make_isolated $*