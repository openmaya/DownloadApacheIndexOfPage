ROOT_URL=$1
ROOT_DIR=$2

function downloadSite () { 
	echo "### download start"
	echo "#$(pwd)"
	echo "#### if dir=$2 is not found then mkdir"
	if [ -e $2 ]; then
		if [ -d $2 ]; then
			echo "# $2 is directory"
		else
			echo "# $2 is not directory"
		fi
	else
		echo "# $2 don't exist, so mkdir"
		mkdir $2
	fi
	ls -al $2
	echo "### change directory dir=$2"
	cd $2
	echo "# change directory $(pwd)"
	echo "### print file list and download dir=$2 sub file"
	if [ -e index.html ]; then
		echo "# rm index.html"
		rm index.html
	fi
	echo "# download $1 index.html"
	curl -o index.html $1
	if [ -e index.html ]; then
		for file in $(cat ./index.html | sed -ne "/<pre>/,/<\/pre>/s/.*\(A HREF\|a href\)=\"\([^>]*\.[^>]*\)\".*/\2/p")
		do
			FILE_URL="$1$file"
			echo "# download :: $FILE_URL";
			if [ -e $file ]; then
				echo "rm $FILE_URL"
				rm $file
			fi
			curl -O $FILE_URL
		done
		echo "### print directory list and call $0 $1[DIRECTORY] $2[DIRECTORY]"
		for dir in $(cat ./index.html | sed -ne "/<pre>/,/<\/pre>/s/.*\(A HREF\|a href\)=\"\([^\/\.]*\/\)\".*/\2/p")
		do
			echo "# call downloadSite :: $1$dir, $dir"
			downloadSite "$1$dir" "$dir"
		done
	else
		echo "$1/index.html is not found(maybe 404 return)"
	fi
	echo "# rm $(pwd) index.html"
	rm index.html
	cd ..
	echo "### change parent directory dir=$(pwd)"
	
	echo "# complete download :: $1, $dir"
	echo "### download end"
}

if [ $# -ne 2 ]; then
	echo "USAGE : $0 [ROOT_URL] [ROOT_DIR]"
else
	downloadSite $ROOT_URL $ROOT_DIR/
fi
