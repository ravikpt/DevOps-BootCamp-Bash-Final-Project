#!/bin/curl

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
   # filePath=$(echo "$1" | sed s:"~":"$HOME":g)
   filePath=$i ; echo "${i//~/$HOME}"

   if [ ! -f "$filePath"]; then
        {
                echo "Error: invalid file path";
                return 1;
   };
   fi

   tempFileName=$(echo "$1" | sed "s/.*\///")

   echo "Uploading $tempFileName"

   httpSingleUpload "$filePath" "$tempFileName"
  done
}

singleUpload "$1" || exit 1

printUploadResponse
