termColorFont
=============

function battery for terminal color and font support

public functions
----------------
 
* `TERM_COLOR_FG( color, type )` 
 * set terminal foreground color

* `TERM_COLOR_FG( color, type )`
 * set terminal background color

* `TERM_COLOR_RESET()`
 * resets colors but not font settings

### Possible Values: 

* `color` is a string, out of:
 * red, blue, green, yellow, hibiscus, peach, orange, indigo, 
   aquamarine, turquoise, magenta, sand, white
 * **note**: internally, only the first letter is used, so it is sufficient to use a char out of [r,b,g,y,h,p,o,i,a,t,m,s,w]
* `type` is a number, out of:
 * 1 (bright) to 5 (dark) -- all colors
 * and 0 (logo-like) -- only for red yellow green blue
 * defaults to 3
