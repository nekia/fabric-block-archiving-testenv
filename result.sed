/^"{/ {
  :x
  /^}"$/ {
    i ,
    d
  }
  /^"{$/ {
    s/"//
    p
    n
    bx;
  }
  /fileSuffixNum/ {
    s/^"{\(.*\)}"/\1/
    a }
    p
    d
  }
  p
  n
  bx;
}
/^"[[:digit:]]\+"$/ {
  s/^"\([[:digit:]]\+\)"$/"blocksize": \1,/
  p
  n
}
