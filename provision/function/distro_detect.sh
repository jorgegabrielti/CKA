# Test: [OK]
_distro_detect () {
  echo -e "\e[40;32;1m[TASK]: distro_detect\e[m\n"
  DISTRO="$(grep -Ei 'PRETTY_NAME' /etc/os-release | cut -d'=' -f2 | tr -d '"'  | cut -d'.' -f1,2)"
  
  case ${DISTRO} in
    "Ubuntu 20.04")
      echo -e "\tDistro: [${DISTRO}]\n"
    ;;
    *)
      echo "Distro: [${DISTRO}] ==> Not supported!"
    ;;
  esac
}