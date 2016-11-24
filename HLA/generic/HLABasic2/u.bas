black = 0
red = 1
green = 2
yellow = 3
blue = 4
magenta = 5
cyan = 6
white = 7


beep
cls
color yellow, blue
print "color yellow, blue"
color black, white
print "color black, white"
color white, black
print "color white, black"
gotoxy 10, 10
print "gotoxy 10, 10"
gotoxy 0, 12
print "gotoxy 0, 12"

i = 1.0
print "i=", i
j = 1.1
print "j=", j
k = 1
print "k=", k
l = 1000
print "l=", l
m = 100000
print "m=", m

n = acos( 0.9 )
print "n=", n
o = asc( "A" )
print "o=", o
p = asin( 0.9 )
print "p=", p
q = atan( 0.9 )
print "q=", q
r = chr( 65 )
print "r=", r 
s = cos( 1.0 )
print "s=", s 

t = dim( 3 )
t[0] = 1
t[1] = 2.0
t[2] = "three"
print "t[0]=", t[0]
print "t[1]=", t[1]
print "t[2]=", t[2]

u = exp( 1.0 )
print "u=", u 
v = int( 1.6 )
print "v=", v
w = left( "Hello", 2 )
print "w=", w
x = len( w )
print "x=", x 
y = log( 1.0 )
print "y=", y 
z = mid( "Hello", 2, 2 )
print "z=", z
a = randomize
print "a=", a
b = right( "Hello", 2 )
print "b=", b
c = rnd
print "c=", c
d = round( 1.6 )
print "d=", d
e = sin( 1.0 )
print "e=", e

f = sqrt( 2.0 )
print "f=", f
g = str( 1 )
print "g=", g
h = str( 1,2 )
print "h= '";h;"'"
i = str( 1, -2 )
print "i= '";i;"'"
j = str( 1.0 )
print "j='"; j; "'"
k = str( 1.0, 12 )
print "k= '";k;"'"
l = str( 1.0, 8, 3 )
print "l= '";l;"'"
m = tan( 1.0 )
print "m=", m
n = val( "1" )
print "n=", n
o = val( "1.0" )
print "o=", o+1

p = 0 < 1
print "p=";p
q = 1 < 0
print "q=";q
print "q=";q, "p=";p
r = 1 < 1
print "r=";r
print "p=";p, "q=";q, "r=";r

s = 0 <= 1
print "s=";s
t = 1 <= 0
print "t=";t
u = 1 <= 1
print "u=";u
print "s=";s, "t=";t, "u=";u

v = 0 > 1
print "v=";v
w = 1 > 0
print "w=";w
x = 1 > 1
print "x=";x
print "v=";v, "w=";w, "x=";x

y = 0 >= 1
print "y=";y
z = 1 >= 0
print "z=";z
a = 1 >= 1
print "a=";a
print "y=";y, "z=";z, "a=";a

b = 0 = 1
print "b=";b
c = 1 = 1
print "c=";c
print "b=";b, "c=";c

d = 0 <> 1
print "d=";d
e = 1 <> 1
print "e=";e
print "d=";d, "e=";e

f = 0 or 1
print "f=";f
g = 1 or 1
print "g=";g
h = 0 or 0
print "h=";h
i = 1 or 0
print "i=";i

j = 0 and 1
print "j=";j
k = 1 and 1
print "k=";k
l = 0 and 0
print "l=";l
m = 1 and 0
print "m=";m

n = not 0
print "n=";n
o = not 1
print "o=";o

p = -0
print "p=";p
q = -1
print "q=";q

r = -0.0
print "r=";r
s = -1.0
print "s=";s

print "2+3=", 2+3
print "2-3=", 2-3
print "3-2=", 3-2

print "2.0+3=", 2+3.0
print "2.0-3=", 2-3.0
print "3.0-2=", 3-2.0

print "2*3=", 2*3
print "2/6=", 2/6
print "6/2=", 6/2
print "2 mod 6=", 2 mod 6
print "6 mod 2=", 6 mod 2 

print "2.0*3.0=", 2.0*3.0
print "2.0/6.0=", 2.0/6.0
print "6.0/2.0=", 6.0/2.0

t = dim( 3 )
t[0] = 1
t[1] = 2
t[2] = 3
print "t=",t[0], t[1], t[2]
u = (4-t[0])*(2+t[1])-t[2]
print "u=", u

print "Zero execution forloop"
for k = 3 to 1
	print "should not print"
next k
print "After zero execution forloop"

for i=0 to 3
	print "for i=", i
next i

for j=0 to 10 step 2
	print "for j=", j
next j

for k=3 to 0 step -1
	print "for k=", k
next k

for l= -1 to -10 step -2
	print "for l=", l
next l

print "Calling func1"
gosub func1
print "Returned from func1"

print "goto stmt1"
goto stmt1

	print "should not execute"
	
stmt1:
print "At stmt1"

print "testing IF(true)"
if( 1 ) then
	print "IF(1) succeeded"
endif

print "testing IF(false)"
if( 0 ) then
	print "IF(0) failed!"
endif
print "IF tests done"

print "Testing IF(true)/ELSE"
if( 1 ) then
	print "IF(1) succeeded!"
else
	print "IF(1)/ELSE failed!"
endif

print "Testing IF(false)/ELSE"
if( 0 ) then
	print "IF(0)/ELSE failed"
else
	print "IF(0)/ELSE succeeded!"
endif
print "IF/ELSE tests done"

print
print "Testing on..gosub"
for m = 0 to 3 
	if( m <> 3 ) then
		print "on..gosub calling func"; m+1
	else
		print "on..gosub falling through"
	endif
	on m gosub func1, func2, func3
	print "return from on..gosub, m="; m
next m

print
print "Testing on..goto"
for m = 0 to 3 
	if( m <> 3 ) then
		print "on..goto calling lbl"; m+1
	else
		print "on..goto falling through"
	endif
	on m goto lbl1, lbl2, lbl3
  rtnLbl:
	print "return from on..goto, m="; m
next m

print
print "Testing while"
i = 0
while( i < 10 ) do
	print "while i=", i
	let i = i + 1
endwhile
print "While done"
print

print "Waiting one second:";
wait 1
print "...wait complete"

print "suspending"
suspend
print "resumed"

print
print "Enter an integer value: ";
input a
print "Entered: ", a

print "Enter a real value: ";
input b
print "Entered: ", b

print "Enter a string:";
readln c
print "string ='"; c; "'"

print "Enter '1' to stop program, '2' to reset (by running off end):"
input d
if( d = 2 ) then

	goto offEnd
	
endif
stop

func1:
	print "func1 executed"
	return
	
func2:
	print "func2 executed"
	return
	
func3:
	print "func3 executed"
	return

lbl1:
	print "lbl1 executed"
	goto rtnLbl
	
lbl2:
	print "lbl2 executed"
	goto rtnLbl
	
lbl3:
	print "lbl3 executed"
	goto rtnLbl
	
offEnd:
