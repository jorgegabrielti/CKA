# Test: [OK]
_packages_install () {

  echo -e "\e[40;32;1m[TASK]: packages_install\e[m\n"
  for ((c=0 ; c<=$(wc -l ${WORK_DIR}/provision/conf/packages.txt | awk '{print $1}'); c++))
  do 
    PACKAGE[$c]="$(cat ${WORK_DIR}/provision/conf/packages.txt | head -n$(($c + 1)) | tail -n1)"
  done
  sudo apt update 
  sudo apt install -y ${PACKAGE[*]}

}