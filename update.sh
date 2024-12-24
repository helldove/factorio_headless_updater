#!/bin/bash
FULL_PATH=$(realpath $0)
DIR_PATH=$(dirname $FULL_PATH)
ELF_PATH="$DIR_PATH/factorio/bin/x64/factorio"
CURR_VERSION=""

if [[ ! -f "$ELF_PATH" ]]; then
	CURR_VERSION="Not Installed"
else
	CURR_VERSION="$($ELF_PATH --version | grep 'Version' | head -1 | awk '{print $2}' | grep -Po '[0-9\.]+')"
fi

CHK_VERSION="$(curl https://factorio.com/get-download/stable/headless/linux64 -s --max-redirs 0 | head -5 | tail -1 | grep -Po 'releases/[0-9\.]*_' | grep -Po '[0-9\.]+' | head -1)"

echo "Current version: $CURR_VERSION"
echo "Latest version: $CHK_VERSION"


if [[ "${CURR_VERSION}" == "${CHK_VERSION}" ]]; then
	echo "Already latest version."
else
	echo "Update start."
	`wget -q https://factorio.com/get-download/stable/headless/linux64 -O factorio.tar.xz`
	`tar -xvf factorio.tar.xz; rm -rf factorio.tar.xz`
	
	
	UPDATE_VERSION="$($ELF_PATH --version | grep 'Version' | head -1 | awk '{print $2}' | grep -Po '[0-9\.]+')"
	if [[ ! -L "$DIR_PATH/factorio/saves" ]]; then
		`ln -s "$DIR_PATH/saves" "$DIR_PATH/factorio/saves"`
	fi

	if [[ -d "$DIR_PATH/settings" ]]; then
		for setting in "$DIR_PATH/settings"/*
		do
			LINK_NAME=$(echo -n $setting | sed -E 's/([^\/]+\/)*//g')
			if [[ ! -L "$DIR_PATH/factorio/data/$LINK_NAME" ]]; then
				`ln -s "$setting" "$DIR_PATH/factorio/data"`
			fi
		done
	fi

	echo "Update complete: ${CURR_VERSION} -> ${UPDATE_VERSION}"
fi
