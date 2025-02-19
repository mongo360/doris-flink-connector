#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

##############################################################
# This script is used to compile Flink-Doris-Connector
# Usage:
#    sh build.sh
#
##############################################################

set -eo pipefail

ROOT=$(dirname "$0")
ROOT=$(cd "$ROOT"; pwd)

export DORIS_HOME=${ROOT}/../

usage() {
  echo "
  Usage:
    $0 --flink version # specify flink version (after flink-doris-connector v1.2 and flink-1.15, there is no need to provide scala version)
    $0 --tag           # this is a build from tag
  e.g.:
    $0 --flink 1.16.0
    $0 --tag
  "
  exit 1
}

# we use GNU enhanced version getopt command here for long option names, rather than the original version.
# check the version of the getopt command before using.
getopt -T > /dev/null && echo "
  The GNU version of getopt command is required.
  On Mac OS, you can use Homebrew to install gnu-getopt:
    1. brew install gnu-getopt                  # install gnu-getopt
    2. GETOPT_PATH=\`brew --prefix gnu-getopt\`   # get the gnu-getopt execute path
    3. export PATH=\"\${GETOPT_PATH}/bin:\$PATH\"         # set gnu-getopt as default getopt
" && exit 1

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -o 'h' \
  -l 'flink:' \
  -l 'tag' \
  -- "$@")

if [ $# == 0 ] ; then
    usage
fi

eval set -- "$OPTS"

. "${DORIS_HOME}"/env.sh

# include custom environment variables
if [[ -f ${DORIS_HOME}/custom_env.sh ]]; then
    . "${DORIS_HOME}"/custom_env.sh
fi

BUILD_FROM_TAG=0
FLINK_VERSION=0
while true; do
    case "$1" in
        --flink) FLINK_VERSION=$2 ; shift 2 ;;
        --tag) BUILD_FROM_TAG=1 ; shift ;;
        --) shift ;  break ;;
        *) echo "Internal error" ; exit 1 ;;
    esac
done

# extract minor version:
# eg: 1.14.3 -> 1.14
FLINK_MINOR_VERSION=0
if [ ${FLINK_VERSION} != 0 ]; then
    FLINK_MINOR_VERSION=${FLINK_VERSION%.*}
    echo "FLINK_MINOR_VERSION: ${FLINK_MINOR_VERSION}"
fi

if [[ ${BUILD_FROM_TAG} -eq 1 ]]; then
    rm -rf output/
    ${MVN_BIN} clean package
else
    rm -rf output/
    ${MVN_BIN} clean package -Dflink.version=${FLINK_VERSION} -Dflink.minor.version=${FLINK_MINOR_VERSION}
fi

echo "*****************************************"
echo "Successfully build Flink-Doris-Connector"
echo "*****************************************"

exit 0
