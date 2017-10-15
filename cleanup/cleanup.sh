#!/bin/bash

set -e


# Trim trailing whitespace
sed -i 's|\s*$||g' *.c *.h


# build 'ccmtcnvt' for converting C++ comments into C comments.
# (unfortunately it doesn't fix C++ comments inside C comments)
make -C cleanup

for f in *.c *.h ; do
	mv $f $f~
	cleanup/ccmtcnvt $f~ > $f
done


# remove horizontal line breaks like /* ------ */
sed -i 's|/\*\s*---*---*\s*\*/||g' *.c


# remove comments after the closing function brace, like } /* foo() */
sed -i 's|\s*}\s*/\*.*\*/|}|g' *.c


# Insert new cleanup steps above this comment.
# Keep Lindent as the last step.

# Use the kernel's scripts/Lindent utility
if [ -z "$LINDENT" -o ! -x "$LINDENT" ] ; then
	echo " You need to set the LINDENT environment variable to specify where the Lindent script is (Hint: in the kernel sources at scripts/Lindent)"
	exit 1
fi

# Run Lindent twice, because the operation is unfortunately not idempotent
# after only a single run (but is after two runs).
${LINDENT} *.c *.h ; ${LINDENT} *.c *.h

