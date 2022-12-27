#!/bin/bash

currentVersion="1.1.0"

httpSingleUpload()
{
   response=$(curl -A curl -# --upload-file "$1" "https://transfer.sh/$2") || { echo "Failure!"; return 1;}
   printUploadResponse
}

printUploadResponse()
{
fileID=$(echo "$response" | cut -d "/" -f 4)
  cat <<EOF
Transfer File URL: $response
EOF
}

singleUpload()
{
  for i in "$@"
  do
    
    #filePath=$(echo "$i" | sed 's/~/$HOME/g')
    filePath=$i ; echo "${i//~/$HOME}"

    if [ ! -e "$filePath" ]; then
    {
      echo "Error: invalid file path";
      return 1;
    };
    fi

    tempFileName=$(echo "$i" | sed "s/.*\///")
    
    echo "Uploading $tempFileName"

    httpSingleUpload "$filePath" "$tempFileName"
  done
}
printUploadResponse

case "${cmd}" in
  download)
    [ -z "${url}" ] && read -e -p 'Enter url (e.g. https://transfer.sh/abcXYZ/file.log): ' url
  ;;
  upload)
    [ -z "${file}" ] && read -e -p 'Enter file (e.g. /path/to/file.log): ' file
  ;;
esac

# code for dowload file.

function download() {
  if [ -n "${file}" ]; then
    local path=$(greadlink -f "${file}" 2> /dev/null || readlink -f "${file}" 2> /dev/null)

    curl --progress-bar "${url}" |
      ([ -z "${decrypt}" ] && cat || openssl aes-256-cbc -d -a ${password:+-k "${password}"}) > "${path}"

    echo "${path}"
    if type pbcopy &> /dev/null; then echo -n ${path} | pbcopy; fi
  else
    curl --silent "${url}" 2> /dev/null |
      ([ -z "${decrypt}" ] && cat || openssl aes-256-cbc -d -a ${password:+-k "${password}"})
  fi
}

# code for help options

while getopts 'dvh' OPTION; do
  case $OPTION in
    d)
        singleDownload "$2" "$3" "$4"
	exit 0
	;;		  
    v) 
      echo "$currentVersion"
      exit 0
      ;;
    h)
      echo " Description: Bash tool to transfer files from the command line. 
        Usage: 
        -d  Download file from https://transfer.sh/{particular folder} 
        -h  Show the help about attributes. Show examples 
	-v  Get the tool version 
    
      "
      exit 0
      ;; 
      *) echo "use [-v] [-d] [-h]"
         exit 0
         ;;
  esac 
done
