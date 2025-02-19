#!/bin/bash

# Exit on the first command that returns a nonzero code.
set -e

# Function that checks if a given executable is on the path. If it isn't, prints an install message and exits.
# Usage: check_binary EXECUTABLE_NAME INSTALL_MESSAGE
check_binary() {
  if ! which "$1" > /dev/null; then
    # Using a subshell to redirect output to stderr. It's cleaner this way and will play nice with other redirects.
    # https://stackoverflow.com/a/23550347/225905
    ( >&2 echo "$2" )
    # Exit with a nonzero code so that the caller knows the script failed.
    exit 1
  fi
}

check_binary "jq" "$(cat <<EOF
you will need jq to run this script.
install it using your package manager. for homebrew:
brew install jq
...
you can see further installation instructions here:
https://jqlang.github.io/jq/download/
EOF
)"

# a dumb command that uses jq in order to provide a SSCCE snippet
# http://sscce.org/
jq -r ".message" <<EOF
{"message": "jq is installed!"}
EOF

#yq is not installed
check_binary "yq" "$(cat <<EOF
you will need yq to run this script.
install it using pip:
pip install yq
...
you can see further installation instructions here:
https://github.com/mikefarah/yq?tab=readme-ov-file#install
EOF
)"

# yq is installed
yq -r ".message" <<EOF
{"message": "yq is installed!"}
EOF

# get project filename
# check for a .als file in current directory
stat *.als &> /dev/null
if [ "$?" == 0 ]; then
  #if file exists, cut off the extension and continue
  name="$(ls | grep *.als | sed "s/.als//")"
  echo "performing operation on $name.als"
else
  #if file does not exist, ask for the project name
  echo "project file not found :("
  read -p "enter ableton project name **WITHOUT FILE EXTENSION**: " name
fi
# get first desired track for printing
read -p "enter index of first track with clips (starting from 0): " ftrack
# get last desired track for printing
read -p "enter index of last track with clips (starting from 0): " ltrack
# indicate relinquishing of control to the computer
echo "ready to go!"
echo "converting .als to .xml..."
gzip -cd "$name".als > "$name".xml
echo "converting .xml to .json..."
cat "$name".xml | xq . > "$name".json
echo "printing to $name.txt..."
# replace [track.first..track.last] with midi track # range (starting from 0)
for i in $(seq "$ftrack" "$ltrack")
do
  # iteratively index each clip name from $i
  cat "$name".json | jq .Ableton.LiveSet.Tracks.MidiTrack["$i"] | jq '[.DeviceChain.MainSequencer.ClipTimeable.ArrangerAutomation.Events | {name: .MidiClip[].Name}]' | grep Value | cut -d: -f2 | sed 's/"//g'
 done > "$name".txt
echo "printed to $name.txt!"
echo "cleaning up..."
rm "$name".xml
rm "$name".json
echo "export to text complete!"
