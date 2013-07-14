#!/bin/bash

###########################################################################
#                                   doc                                   #
###########################################################################

# WORK IN PROGRESS

# http://ctags.sourceforge.net/FORMAT
# http://vimdoc.sourceforge.net/htmldoc/tagsrch.html

# TAG LINE: {tagname}<Tab>{tagfile}<Tab>{tagaddress}[;"<Tab>{tagfield:tagfieldvalue}..]
# EG TAG  : main	/Users/anthony.jackson/src/main.c	/^main()/;"	kind:f	file:

###########################################################################
#                                 helpers                                 #
###########################################################################

# grep -n -e "expression" file
grep_linenum() { awk -F':' '{ print $1; }' }
grep_linecontent() { awk -F':' '{ for(i=2;i<NF+1;i++){printf "%s",$i}; }' }

###########################################################################
#                                  main                                   #
###########################################################################


# find all *.[he]rl files
for FILEPATH in `find ~/svn/modules/ -name '*.[he]rl'`; do

  FILENAME=$(basename $FILEPATH)
  MODULE="${FILENAME%.*}"
  MODULELINE=`grep -n -e "-module($MODULE)" $FILENAME`
  # TODO check the line is not empty
  LN=$(printf %s $MODULELINE | grep_linenum)
  LC=$(printf %s $MODULELINE | grep_linecontent | sed -e 's/\\/\\\\/g')
  echo "$FILENAME\t$FILEPATH\t/$LC/;\"kind:F" >> ~/svn/modules/erl_tags

  # TODO identify exported functions
  EXPORTED=`pcregrep -M -e '-export\(\s*\[(\n|.)*?\]\s*\)\s*' $FILEPATH | grep -oP '\w+(?=/\d+)'`

  for line in `cat $FILEPATH`; do
    # find functions
    FUNCTION=`grep -n -e '^\w+(' ./yaws/test/src/$FILENAME`
    # TODO check the line is not empty
    LN=$(printf %s $FUNCTION | grep_linenum)
    LC=$(printf %s $FUNCTION | grep_linecontent | sed -e 's/\\/\\\\/g')

    # add tag for private functions with fields kind:f file:
    if [[ condition ]]; then
      #statements
    fi
    # TODO

    # add tag for exported functions with fields kind:f
    # TODO
  done
done

# TODO sort file

# vim: set ft=sh :
