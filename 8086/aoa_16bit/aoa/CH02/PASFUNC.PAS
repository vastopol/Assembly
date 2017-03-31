program GenericFunc(input,output);
type
    gftype = array [0..15] of integer;

var
   a, b, c, d:integer;
   fresult:integer;
   func: gftype;


(* Standard Pascal does not provide the ability to shift integer data   *)
(* to the left or right.  Therefore, we will simulate a 16-bit value    *)
(* using an array of 16 integers.  We can simulate shifts by moving     *)
(* data around in the array.                                            *)
(*                                                                      *)
(* Note that Turbo Pascal *does* provide shl and shr operators.  How-   *)
(* ever, this code is written to work with standard Pascal, not just    *)
(* Turbo Pascal.                                                        *)

procedure ShiftLeft(shiftin:integer);
var i:integer;
begin

     for i := 15 downto 1 do func[i] := func[i-1];
     func[0] := shiftin;

end;

procedure ShiftNibble(d,c,b,a:integer);
begin

     ShiftLeft(d);
     ShiftLeft(c);
     ShiftLeft(b);
     ShiftLeft(a);
end;


procedure ShiftRight;
var i:integer;
begin

     for i := 0 to 14 do func[i] := func[i+1];
     func[15] := 0;

end;

procedure toupper(var ch:char);
begin

     if (ch in ['a'..'z']) then ch := chr(ord(ch) - 32);

end;

function ReadFunc:integer;
var ch:char;
    i, val:integer;
begin

     write('Enter function number (hexadecimal): ');
     for i := 0 to 15 do func[i] := 0;
     repeat

           read(ch);
           if not eoln then begin

                      toupper(ch);
                      case ch of
                           '0': ShiftNibble(0,0,0,0);
                           '1': ShiftNibble(0,0,0,1);
                           '2': ShiftNibble(0,0,1,0);
                           '3': ShiftNibble(0,0,1,1);
                           '4': ShiftNibble(0,1,0,0);
                           '5': ShiftNibble(0,1,0,1);
                           '6': ShiftNibble(0,1,1,0);
                           '7': ShiftNibble(0,1,1,1);
                           '8': ShiftNibble(1,0,0,0);
                           '9': ShiftNibble(1,0,0,1);
                           'A': ShiftNibble(1,0,1,0);
                           'B': ShiftNibble(1,0,1,1);
                           'C': ShiftNibble(1,1,0,0);
                           'D': ShiftNibble(1,1,0,1);
                           'E': ShiftNibble(1,1,1,0);
                           'F': ShiftNibble(1,1,1,1);
                           else write(chr(7),chr(8));
                      end;
           end;
     until eoln;
     val := 0;
     for i := 0 to 15 do val := val + func[i];
     ReadFunc := val;
end;


(* Generic - Computes the generic logical function specified by *)
(*           the function number "func" on the four input vars  *)
(*           a, b, c, and d.  It does this by returning bit     *)
(*           d*8 + c*4 + b*2 + a from func.  This version re-   *)
(*           lies on Turbo Pascal's shift right operator.       *)

function Generic(var func:gftype; a,b,c,d:integer):integer;
begin
          Generic := func[a + b*2 + c*4 + d*8];
end;


begin (* main *)

      repeat

            fresult := ReadFunc;
            if (fresult <> 0) then begin

               write('Enter values for D, C, B, & A (0/1):');
               readln(d, c, b, a);
               writeln('The result is ',Generic(func,a,b,c,d));

            end;
      until fresult = 0;

end.