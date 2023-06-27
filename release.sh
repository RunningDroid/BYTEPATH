#!/bin/sh -eu
#
# build release binaries for Windows and Linux

current_love_release='11.4'

# get the path to the repo
repo_dir="$(realpath "$(dirname "$0")")"
cd "$repo_dir"

(
	# separated by '' (Unit Separator (0x1F) usually rendered as '^_') (Ctrl-v Ctrl-Shift--)
	generated_files="BYTEPATH.loveBYTEPATH-win32.zipBYTEPATH.AppImagegame_64.AppImage"

	# set IFS to Unit Separator (GitHub doesn't render control characters)
	IFS=''
	for file in ${generated_files}; do
		if [ -e "$file" ]; then
			rm "$file"
		fi
	done
)

# some stuff in the repo doesn't need to be included in the release
zip -9 --recurse-paths BYTEPATH.love \
	libraries objects resources rooms \
	./*.lua LICENSE README.md \
	--exclude resources/BYTEPATH.desktop \
	--exclude '*/.git*' --exclude '*/.travis*'

tmp_dir="$(mktemp -d)"
cd "$tmp_dir"

# create a Windows executable
curl --disable --location --output 'love-win32.zip' \
	"https://github.com/love2d/love/releases/download/${current_love_release}/love-${current_love_release}-win32.zip"

mkdir love-win32
unzip love-win32.zip -d love-win32
love_dir_name="$(basename love-win32/* )"

cd "love-win32/$love_dir_name"

rm 'readme.txt'
cat "love.exe" "${repo_dir}/BYTEPATH.love" > "BYTEPATH.exe"

cd ..

mv "$love_dir_name" 'BYTEPATH'
zip -9 --recurse-paths 'BYTEPATH-win32.zip' 'BYTEPATH'
mv 'BYTEPATH-win32.zip' "$repo_dir"

cd "$tmp_dir"

# create a Linux appimage
mkdir love-lin64
cd love-lin64

curl --disable --location --output 'love-x86_64.AppImage' \
	"https://github.com/love2d/love/releases/download/${current_love_release}/love-${current_love_release}-x86_64.AppImage"
curl --disable --location --remote-name 'https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage'

chmod +x 'love-x86_64.AppImage' 'appimagetool-x86_64.AppImage'
./love-x86_64.AppImage --appimage-extract

cat 'squashfs-root/bin/love' "${repo_dir}/BYTEPATH.love" > 'squashfs-root/bin/BYTEPATH'
chmod +x 'squashfs-root/bin/BYTEPATH'

rm 'squashfs-root/love.desktop'
cp "${repo_dir}/resources/BYTEPATH.desktop" 'squashfs-root/'

./appimagetool-x86_64.AppImage 'squashfs-root' 'BYTEPATH.AppImage'

mv 'BYTEPATH.AppImage' "$repo_dir"

cd "$repo_dir"
rm -r "$tmp_dir"
cp 'BYTEPATH.AppImage' 'game_64.AppImage'
