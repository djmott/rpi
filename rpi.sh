#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

main(){
  cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )")"
  export _RPI_DIR="$PWD"
  if [ -f "$_RPI_DIR"/.rpi.conf ]; then source "$_RPI_DIR"/.rpi.conf; fi
	export _R="$(tput setaf 1)"
	export _G="$(tput setaf 2)"
	export _Y="$(tput setaf 3)"
	export _B="$(tput setaf 4)"
	export _Z="$(tput sgr0)"
  export _RPI_TARGET=${_RPI_TARGET:-armv8-rpi3-linux-gnueabihf}
  export _RPI_TOOLCHAIN=${_RPI_TOOLCHAIN:-"$_RPI_DIR"/toolchain/build}
  export _RPI_SYSROOT=${_RPI_SYSROOT:-"$_RPI_DIR"/toolchain/build/$_RPI_TARGET/sysroot}
  export _RPI_ROOTFS=${_RPI_ROOTFS:-"$_RPI_DIR"/rootfs}
  export _RPI_TMP=${_RPI_TMP:-"$_RPI_DIR"/.tmp}
  export _RPI_DOWNLOADS=${_RPI_DOWNLOADS:-"$_RPI_DIR"/.download}
  trap _atexit INT TERM EXIT
  mkdir -p $_RPI_ROOTFS $_RPI_TMP $_RPI_DOWNLOADS
  $*
  return 0
}

_atexit(){
  local _ret=$?
  if [ "0" != "$_ret" ]; then
    echo -e "$_R  Exiting with code: $_ret $_Z"
  else
    printenv | sort | grep "^_RPI_" > "$_RPI_DIR"/.rpi.conf
  fi
  exit $_ret
}

help(){
  echo -e "
Usage: $0 $_G<command>$_Z

Commands:
  $_G help $_Z            - this information
  $_G qemu $_Z            - enter emulated chroot
  $_G shell $_Z           - enter dev shell
  "
}

-help(){ help; }
--help(){ help; }
-h(){ help; }
--h(){ help; }
-?(){ help; }
--?(){ help; }

shell(){
  export PS1="${_R}rpi shell${_G} \w ${_Z}> "
  reset
  echo -e "Entering rpi dev shell. Type '${_R}exit${_Z}' to return.
  
  Environment:
${_Y}$(printenv | sort | grep "^_RPI_")${_Z}

  "
  
  bash -norc -noprofile
}

main $*
exit 0