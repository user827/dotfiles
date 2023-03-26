#!/bin/bash
#
# Description:
#
#    Prints a color table of 8bg * 8fg * 2 states (regular/bright)
#
# Copyright:
#
#    (C) 2009 Wolfgang Frisch <xororand@unfoog.de>
#
# License:
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

echo
echo Table for 16-color terminal escape sequences.
echo Replace ESC with \\033 in bash.
echo
echo "Background | Foreground colors"
echo "----------------------------------------------------------------------"
for((bbright=0;bbright<=1;bbright++)) do
  for((bgi=40;bgi<=47;bgi++)); do
    for((bright=0;bright<=1;bright++)) do
      if [ $bbright == "1" ]; then
	bg=$(( bgi + 60 ))
      else
	bg=$bgi
      fi
      printf '\033[m %-11s%s' "ESC[${bg}m   " "| "
      for((fgi=30;fgi<=37;fgi++)); do
	if [ $bright == "1" ]; then
	  fg=$(( fgi + 60 ))
	else
	  fg=$fgi
	fi
	echo -en "\033[${bg}m\033[${fg}m [${fg}m  "
      done
      echo -e "\033[0m"
    done
    echo "---------------------------------------------------------------------- "
  done
done

echo
echo
