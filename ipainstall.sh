#!/usr/bin/env bash

#===============================================
# CONFIG (or use parameter 2=IP & 3=OS_TYPE)
#===============================================

# Enter IP of your device if you want auto. install ipa after signing
IP=""
# For ATV4 enter tvOS, for iPxxx enter iOS
OS_TYPE="iOS"

# Check is user enter ipa name
if [[ $# -eq 0 ]] ; then
    echo "You must enter .ipa name for sign!"
    exit 1
fi


#===============================================
# PREPARE IPA
#===============================================

# Export ipa
echo "Preparing $1..."
unzip "$1" "Payload/*" > /dev/null
pushd Payload > /dev/null
APP=$(find . -name "*.app")
mv "$APP" "../"
popd > /dev/null
rm -rf "Payload"
echo ""
echo "Preparing done!"
echo "--------------------------------------------------------------"
echo "Start sign process..."
echo "--------------------------------------------------------------"


#===============================================
# GLOBALS
#===============================================
APP_NAME=$(basename "${APP}")
EXTENSION_TO_SCAN=$2;
ENT_XML='<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>platform-application</key><true/></dict></plist>'
echo $ENT_XML > platform.ent
PLATFORM_ENT="$(pwd)/platform.ent"
APP_DIR_LOCATION="/Applications" # default to iOS 11 stock apps

# Check type of device and set app. dir
if [[ $3 = "tvOS" ]] || [[ $OS_TYPE = "tvOS" ]]; then
	# Apple TV 4 iOS 10.2.2
	APP_DIR_LOCATION="/private/var/mobile/Applications/"
fi


#===============================================
# ARRAYS
#===============================================

# Backup IFS and set it to \n
OLDIFS=$IFS
IFS=$'\n'

# Make array for files without extension (bin file)
files=(`find "$APP" -type f -not -path "*_CodeSignature*"  ! -name "*.*" ! -name "PkgInfo"`)

# Make array for files with spec. file extension
extension=(`find "$APP" -type f -name "*.dylib"`)

# Marge arrays
files_to_sign=("${files[@]}" "${extension[@]}")


#===============================================
# FUNCTIONS
#===============================================

# Export arm64 and sign it with jtool
sign_file() {
	F_PATH=$1
	DIR_NAME=${F_PATH%/*}
	FILE_NAME=${F_PATH##*/}

	# export ARM64 bin from file (iOS 11 support only 64bit anyway)
	pushd $DIR_NAME > /dev/null
	jtool -e arch -arch arm64 "${FILE_NAME}"

	# sign file
 	jtool --sign --ent $PLATFORM_ENT --inplace $FILE_NAME".arch_arm64"
 	echo "Signing file $FILE_NAME..."

 	# remove old file
	rm $FILE_NAME;

	# rename new file to original filename
	mv $FILE_NAME".arch_arm64" $FILE_NAME

	popd > /dev/null
}


#===============================================
# SIGN FILE/s
#===============================================

# Loop trought array and export/sign every file
for file in "${files_to_sign[@]}"
do
	# Sign file
	sign_file $file
done
# Restore IFS
IFS=$OLDIFS

echo "--------------------------------------------------------------------------------------"
echo "Signing done!"
echo "You can now manual copy $APP_NAME to $APP_DIR_LOCATION and uicache/respring device."
echo "--------------------------------------------------------------------------------------"

# Clean up
rm "platform.ent"

#===============================================
# INSTALL IPA TO DEVICE AND CLEAN UP !
#===============================================

# If user enter IP of iOS than install app to device
if [[ $2 ]] || [ $IP ]; then

	# Check is config have IP
	if [[ $2 ]]; then
		IP_ADDR=$2
	else
		IP_ADDR=$IP
	fi

	# Archive .app
	echo "Packing app $APP_NAME..."
	echo "--------------------------------------------------------------------------------------"
	COPYFILE_DISABLE=1 tar czf "${APP_NAME%\.*}.tar.gz" "${APP_NAME}"
	echo "--------------------------------------------------------------------------------------"
	echo "Enter password (default alpine) to upload ${APP_NAME%\.*} to device at IP $IP_ADDR..."
	echo "--------------------------------------------------------------------------------------"
	scp "${APP_NAME%\.*}.tar.gz" root@$IP_ADDR:~
	echo "--------------------------------------------------------------------------------------"
	echo "Upload done, enter your password one more time to complete the process..."
	echo "--------------------------------------------------------------------------------------"
	echo "Installing ${APP_NAME%\.*}, please wait..."
	ssh root@$IP_ADDR "tar -xvf ${APP_NAME%\.*}.tar.gz -C $APP_DIR_LOCATION > /dev/null && rm ${APP_NAME%\.*}.tar.gz && uicache"
	echo "Process completed, if everything went right you will see new icon on your device."
	echo "Enjoy!"
	echo "--------------------------------------------------------------------------------------"

	# CLEAN UP
	rm -rf ${APP_NAME}
	rm "${APP_NAME%\.*}.tar.gz"
fi