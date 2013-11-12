export BAGGAGE_CONFIG_FILE="Baggage"
export BAGGAGE_DEBUG=0

app_name()
{
  echo "$BAGGAGE_APP_NAME"
}

app_dir()
{
  # TODO - fix this
  echo "$(dirname $0)"
}

in_baggage_root?()
{
  [ -r "./${BAGGAGE_CONFIG_FILE}" ]
}

usage()
{
  echo "usage"
}

version()
{
  echo "$BAGGAGE_APP_VERSION"
}

enable_debug()
{
  BAGGAGE_DEBUG=1
}

global_args()
{
  [ $# -eq 0 ] && usage

  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help) usage;;
      --version) version;;
      --debug)   enable_debug; shift; continue;;
      --trace)   set -x; set -o functrace; shift; continue;;
      --)        shift; break;;
    esac
    shift
  done
}

app_args()
{
  [ $# -eq 0 ] && usage

  #while [ $# -gt 0 ]; do
    case "$1" in
      "test")     shift; load test; run_tests $@;;
      "new")      shift; load new; new $@;;
      "build")    shift; load build; build $@;;
      "install")  shift; load install; install $@;;
      "run")      shift; load run; run $@;;
      "thisisdumb") shift; load new; thisisdumb $@;;
    esac
  #done
}

parse_args()
{
  global_args $@
  app_args $@
}
