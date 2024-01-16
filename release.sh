#!/bin/sh -eu
#
# build release binaries for Windows and Linux

current_love_release='11.4'

# get the path to the repo
repo_dir="$(realpath "$(dirname "$0")")"
cd "$repo_dir"


if [ -e build ]; then
	rm -r build
fi

mkdir build

# some stuff in the repo doesn't need to be included in the release
zip -9 --recurse-paths build/BYTEPATH.love \
	libraries objects resources rooms \
	./*.lua LICENSE README.md \
	--exclude resources/BYTEPATH.desktop \
	--exclude '*/.git*' --exclude '*/.travis*'

tmp_dir="$(mktemp -d)"
# shellcheck disable=2064
trap "[ -d $tmp_dir ] && rm -r $tmp_dir" 0 1 2 3 # clean up even if we error
cd "$tmp_dir"

#{ grab random libraries
mkdir 'windows32-libraries' 'linux64-libraries'

# Valve kinda requires a login to fetch the steam SDK
# so builds that include the steam_api libs require manual intervention

# grab the steam SDK, which contains the steam_api libs
# we only get a zip archive here if someone (at the same IP?) opens the link in a browser, signs in, and downloads the file
# cleaner link: https://partner.steamgames.com/downloads/steamworks_sdk_158a.zip
curl --disable --location --output 'steamworks_sdk.zip' "https://partner.steamgames.com/downloads/steamworks_sdk_158a.zip"
if [ "$(file --brief --mime-type 'steamworks_sdk.zip')" = 'application/zip' ];then
	# only extract the files we want
	unzip steamworks_sdk.zip 'sdk/redistributable_bin/steam_api.dll' 'sdk/redistributable_bin/linux64/libsteam_api.so'
	sdk=true
else
	# server-side token expired?
	echo "Valve redirected us instead of letting us download the SDK"
	sdk=false
fi

# grab copies of luasteam for win32 & lin64
curl --disable --location --output 'luasteam.dll' 'https://github.com/uspgamedev/luasteam/releases/download/v3.0.0/win32_luasteam.dll'
curl --disable --location --output 'luasteam.so' 'https://github.com/uspgamedev/luasteam/releases/download/v3.0.0/linux64_luasteam.so'

if [ "$sdk" = 'true' ]; then
	mv -t 'windows32-libraries' 'sdk/redistributable_bin/steam_api.dll'
	mv -t 'linux64-libraries' 'sdk/redistributable_bin/linux64/libsteam_api.so'
fi

mv -t 'windows32-libraries' 'luasteam.dll'
mv -t 'linux64-libraries' 'luasteam.so'
#}

#{ create a Windows executable
curl --disable --location --output 'love-win32.zip' \
	"https://github.com/love2d/love/releases/download/${current_love_release}/love-${current_love_release}-win32.zip"

mkdir love-win32
unzip love-win32.zip -d love-win32
love_dir_name="$(basename love-win32/* )"

cd "love-win32/$love_dir_name"

rm 'readme.txt'
cat "love.exe" "${repo_dir}/build/BYTEPATH.love" > "BYTEPATH.exe"

mv -t . "${tmp_dir}"/windows32-libraries/*

cd ..

mv "$love_dir_name" 'BYTEPATH'
zip -9 --recurse-paths 'BYTEPATH-win32.zip' 'BYTEPATH'
mv 'BYTEPATH-win32.zip' "$repo_dir/build"
#}

cd "$tmp_dir"

#{ create a Linux appimage
mkdir love-lin64
cd love-lin64

curl --disable --location --output 'love-x86_64.AppImage' \
	"https://github.com/love2d/love/releases/download/${current_love_release}/love-${current_love_release}-x86_64.AppImage"
curl --disable --location --remote-name 'https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage'

chmod +x 'love-x86_64.AppImage' 'appimagetool-x86_64.AppImage'
./love-x86_64.AppImage --appimage-extract

cat 'squashfs-root/bin/love' "${repo_dir}/build/BYTEPATH.love" > 'squashfs-root/bin/BYTEPATH'
chmod +x 'squashfs-root/bin/BYTEPATH'

mkdir -p 'squashfs-root/lib/lua/5.1/'
mv -t 'squashfs-root/lib/lua/5.1/' "${tmp_dir}"/linux64-libraries/luasteam.so
if [ "$sdk" = 'true' ]; then
	mv -t 'squashfs-root/lib' "${tmp_dir}"/linux64-libraries/*
fi

rm 'squashfs-root/love.desktop'
cp "${repo_dir}/resources/BYTEPATH.desktop" 'squashfs-root/'

if [ "${CI:-'false'}" = 'true' ] ; then
	# we're in a container, fuse won't work
	./appimagetool-x86_64.AppImage --appimage-extract-and-run 'squashfs-root' 'BYTEPATH.AppImage'
else
	./appimagetool-x86_64.AppImage 'squashfs-root' 'BYTEPATH.AppImage'
fi

mv 'BYTEPATH.AppImage' "$repo_dir/build"
#}

cd "$repo_dir/build"
cp 'BYTEPATH.AppImage' 'game_64.AppImage'
