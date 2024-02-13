#!/usr/bin/env bash

#
# This is a wrapper script to make it easier to build for both simulators and real devices, 
#   without the confusion of shitty makefile options that don't work for shit
#
# Example usage:
#   ./build.sh                      ==> Will build the deb for device but won't install to device
#   ./build.sh install              ==> Will build for device and will install to device
#   ./build.sh install debug        ==> Will build debug for device and will install to device
#   ./build.sh install final        ==> Will build final version for device and will install to device
#   ./build.sh install debug final  ==> Will build final version without debug for device and will install to device, even if debug arg is given
#   ./build.sh sim                  ==> Will build for simulator but will not install to simulator, this is for you to handle
#   ./build.sh install sim          ==> Will build for simulator but will not install to simulator even if install arg is given
#

# Global variables that get passed when calling gnu make
INSTALL="";
SIM="";
DEBUG="DEBUG=0";
FINAL="FINALPACKAGE=0";
ROOTLESS="ROOTLESS=0";

# This loop is responsible for looping through all the arguments given and deciding what actions need to be taken
for ARG in "$@"; do
    #echo "ARG = $ARG";
    if [ "$ARG" = "install" ]; then
        if [ "$SIM" != "SIM_BUILD=1" ]; then # Verify the sim arg has not been given before install arg
            INSTALL="install";
        fi
    elif [ "$ARG" = "sim" ]; then
        SIM="SIM_BUILD=1";
        INSTALL=""; # If sim arg was given, overwrite install arg value because installing doesn't work on a simulator.
    elif [ "$ARG" = "debug" ]; then
        DEBUG="DEBUG=1";
    elif [ "$ARG" = "final" ]; then
        FINAL="FINALPACKAGE=1";
        if [ "$DEBUG" = "DEBUG=1" ]; then # Verify the debug arg has not been given before final arg
            DEBUG="DEBUG=0";
        fi
    elif [ "$ARG" = "rootless" ]; then
        ROOTLESS="ROOTLESS=1";
    fi
done

rm -rf .theos && make package ${INSTALL} ${SIM} ${DEBUG} ${FINAL} ${ROOTLESS}