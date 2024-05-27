# Test: [OK]
_containerd_install () { 

  read -p "Want to set up an AWS Profile: [Y/n]" OPTION
  if [ "${OPTION}" == "" -o "${OPTION}" == "N" -o "${OPTION}" == "n" ]; then
    echo "Bye..."
    exit 0
  fi

  echo -e "\e[40;32;1m[TASK]: AWS configure a profile.\e[m\n"
  
  echo "******* WARNING *******"
  echo -e "Have at hand your:
          - Access key ID
          - Secret access key\n"

  read -p "Enter a name for the profile: " AWS_PROFILE_NAME

  while [[ $(aws configure list-profiles | grep ${AWS_PROFILE_NAME}) ]]
  do
    read -p "Profile [${AWS_PROFILE_NAME}] already exists, your want replace it: [N/y]" OPTION
    if [ "${OPTION}" == "N" -o "${OPTION}" == "n" ]; then
      read -p "Enter another name for the profile: " AWS_PROFILE_NAME
    else
      echo "THE PROFILE WILL BE OVERWRITTEN."
      aws configure --profile ${AWS_PROFILE_NAME}
      continue
    fi
  done

  aws configure --profile ${AWS_PROFILE_NAME}
  aws configure list --profile ${AWS_PROFILE_NAME}
}