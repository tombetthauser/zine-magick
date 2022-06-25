
# [ 1 = 1 ] && echo 'true!'
# [ 1 -gt 0 ] && echo 'true!'

# e=echo
# $e hello!

# f='echo goodbye!'
# $f
set -x

l=('hello there!' echo)
read input

$input hello

# ${l[1]} ${l[0]}