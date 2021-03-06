#!/usr/bin/env bash
# ==============================================================================
# Do installtion
# ==============================================================================
# Create by Arondight (shell_way@foxmail.com)
# ==============================================================================

WORKDIR=$(dirname $(readlink -f $0))

function showHelp ()
{
  cat <<'END_OF_HELP' >&2
Usage：
  ./install.sh [Option]...
Options：
  -h, --help        Show this help
  -c, --check       Check if everything is ready
  -i, --install     Install these profiles
  -a, --init        Init these profiles after installtion
Example：
  ./install.sh -a
END_OF_HELP

  return $?
}

function doCheck ()
{
  local path=''
  local ret=0
  local UTILS=(git ln install mkdir rm mv tail grep awk uniq md5sum readlink date)

  echo 'Checking your system first ...'

  for util in ${UTILS[@]}
  do
    echo -ne "Checking ${util} ...\t"
    if ! type $util >/dev/null 2>&1
    then
      echo 'failed'
      return 1
    else
      echo 'ok'
    fi
  done

  for path in ${WORKDIR}/*
  do
    if [[ -d $path ]]
    then
      path=$(readlink -f $path)
      if [[ -x "${path}/check.sh" ]]
      then
        if ! command "${path}/check.sh"
        then
          ret=1
        fi
      fi
      unset path
    fi
  done

  echo 'Checking your system done...'

  return $ret
}

function doInstall ()
{
  local path=''

  echo 'Install profiles begin...'

  for path in ${WORKDIR}/*
  do
    if [[ -d $path ]]
    then
      path=$(readlink -f $path)
      if [[ -x "$path/install.sh" ]]
      then
        if ! command "${path}/install.sh"
        then
          return 1
        fi
      fi
      unset path
    fi
  done

  echo 'Install profiles done...'

  return 0
}

function doInit ()
{
  local path=''

  echo 'Init profiles begin...'

  for path in ${WORKDIR}/*
  do
    if [[ -d $path ]]
    then
      path=$(readlink -f $path)
      if [[ -x "$path/init.sh" ]]
      then
        if ! command "${path}/init.sh"
        then
          return 1
        fi
      fi
      unset path
    fi
  done

  echo 'Init profiles done...'

  return 0
}

# MAIN:
{
  optCheck=0
  optInstall=0
  optInit=0
  optHelp=0

  if [[ 0 -eq $# ]]
  then
    set -- '--help'
  fi

  while true
  do
    case $1 in
      -c|--check)
        shift
        optCheck=1
        ;;
      -i|--install)
        shift
        optInstall=1
        set -- '--check' $@
        continue
        ;;
      -a|--init)
        shift
        optInit=1
        set -- '--install' $@
        continue
        ;;
      -h|--help)
        shift
        optHelp=1
        ;;
      *)
        break
      ;;
    esac
  done

  # show help {
  if [[ 1 -eq $optHelp ]]
  then
    showHelp
    exit 1
  fi
  # }

  # do check {
  if [[ 1 -eq $optCheck ]]
  then
    if ! doCheck
    then
      exit $?
    fi
  fi
  # }

  # do install {
  if [[ 1 -eq $optInstall ]]
  then
    if ! doInstall
    then
      exit $?
    fi
  fi
  # }

  # do init {
  if [[ 1 -eq $optInit ]]
  then
    if ! doInit
    then
      exit $?
    fi
  fi

  exit 0
}

