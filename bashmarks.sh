# Copyright (c) 2010, Huy Nguyen, http://www.huyng.com
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided 
# that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice, this list of conditions 
#       and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#       following disclaimer in the documentation and/or other materials provided with the distribution.
#     * Neither the name of Huy Nguyen nor the names of contributors
#       may be used to endorse or promote products derived from this software without 
#       specific prior written permission.
#       
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED 
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.

# bk -d -s [PATH] tagname - saves the path specified or the current directory against the bookmark
# bk -d -l - list the directory bookmarks
# bk -d -g bookmarkname
# bk -c -s [command] tagname - saves the specified command or the last run command against the bookmark
# bk g[TAB] -Jumps to that bookmark 

# setup file to store bookmarks
if [ ! -n "$SDIRS" ]; then
    SDIRS=~/.sdirs
fi
touch $SDIRS

RED="0;31m"
GREEN="0;33m"


# save current directory to bookmarks
function save {
#    check_help $1
    _bookmark_name_valid "$2"
    if [ -z "$exit_message" ] ; then
        _purge_line "$SDIRS" "export DIR_$2="
        echo "export DIR_$2=\"$1\"" >> $SDIRS
    fi
}

# jump to bookmark
function go {
#	check_help $1
    source $SDIRS
    target="$(eval $(echo echo $(echo \$DIR_$1)))"
    if [ -d "$target" ]; then
        cd "$target"
    elif [ ! -n "$target" ]; then
        echo -e "\033[${RED}WARNING: '${1}' bashmark does not exist\033[00m"
    else
        echo -e "\033[${RED}WARNING: '${target}' does not exist\033[00m"
    fi
}

# print bookmark
#function p {
#    check_help $1
#    source $SDIRS
#    echo "$(eval $(echo echo $(echo \$DIR_$1)))"
#}

# delete bookmark
function del {
    _bookmark_name_valid "$1"
    if [ -z "$exit_message" ] ; then
        _purge_line "$SDIRS" "export DIR_$1="
        unset "DIR_$1"
    fi
}

# print out help for the forgetful
function check_help {
        echo ''
		echo "Usage: "
        echo 'bk -d -s <bookmark_name> - Saves the current directory as "bookmark_name"'
        echo 'bk -d -g <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"'
        echo 'bk -d    <bookmark_name> - Deletes the bookmark'
        echo 'bk -d -l                 - Lists all available bookmarks'
        kill -SIGINT $$
}

# list bookmarks with dirnam
function list {
#    check_help $1
    source $SDIRS
        
    # if color output is not working for you, comment out the line below '\033[1;32m' == "red"
    env | sort | awk '/^DIR_.+/{split(substr($0,5),parts,"="); printf("\033[0;33m%-20s\033[0m %s\n", parts[1], parts[2]);}'
    
    # uncomment this line if color output is not working with the line above
    # env | grep "^DIR_" | cut -c5- | sort |grep "^.*=" 
}


# validate bookmark name
function _bookmark_name_valid {
    exit_message=""
    if [ -z $1 ] ; then
        exit_message="bookmark name required"
        echo $exit_message
    elif [ "$1" != "$(echo $1 | sed 's/[^A-Za-z0-9_]//g')" ]; then
        exit_message="bookmark name is not valid"
        echo $exit_message
    fi
}

# completion command
#function _comp {
#    local curw
#    COMPREPLY=()
#    curw=${COMP_WORDS[COMP_CWORD]}
#    COMPREPLY=($(compgen -W '`_l`' -- $curw))
#    return 0
#}

# ZSH completion command
#function _compzsh {
#    reply=($(_l))
#}

# safe delete line from sdirs
function _purge_line {
    if [ -s "$1" ]; then
        # safely create a temp file
        t=$(mktemp -t bashmarks.XXXXXX) || exit 1
        trap "/bin/rm -f -- '$t'" EXIT

        # purge line
        sed "/$2/d" "$1" > "$t"
        /bin/mv "$t" "$1"

        # cleanup temp file
        /bin/rm -f -- "$t"
        trap - EXIT
    fi
}


#if [ $ZSH_VERSION ]; then
#   compctl -K _compzsh g
#    compctl -K _compzsh p
#    compctl -K _compzsh d
#else
#    shopt -s progcomp
#    complete -F _comp g
#    complete -F _comp p
#    complete -F _comp d
#fi


function bk {
#	unset OPTIND
	while true ; do
		case $1 in 
			-d)
				storage="dir" 
				shift
				case $1 in
					-s)
						shift
						path_or_bkname=$1
						shift
						if [ -z $1 ]
						then 
# No path specified using current path
							save $(pwd) $path_or_bkname											
						else
# Path specified is being used
							save $path_or_bkname $1
						fi
						;;
					
					-g)
						shift
						go $1
						;;
	
					-l)
						list
						;;
					-d)
						shift
						del $1
						;;
					-h)
						check_help
						;;		
					-*)
						echo "Invalid usage1"			
						check_help
						;;
				esac
				break
				;;	
			-c)
				c
				break
				;;
		
			-h)
				check_help
				;;
			-*)
				echo "Invalid usage"
				check_help
				break
				;;
		esac
	done

}


