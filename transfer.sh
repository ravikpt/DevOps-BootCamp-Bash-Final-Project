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
