program GenericFunc(input,output);
const
     hex = ['a'..'f', 'A'..'F'];
     decimal= ['0'..'9'];

var
   a, b, c, d:integer;
   fresult:integer;
   func: integer;


(* Here is a second version of the Pascal generic function that uses *)
(* the features of Turbo Pascal to simplify the program.             *)


function ReadFunc:integer;
var ch:char;
    i, val:integer;
begin

     write('Enter function number (hexadecimal): ');
     repeat

           read(ch);
           func := 0;
           if not eoln then begin

              if (ch in Hex) then
                 func := (func shl 4) + (ord(ch) and 15) + 9
              else if (ch in Decimal) then
                 func := (func shl 4) + (ord(ch) and 15)
              else write(chr(7));

           end;
     until eoln;
     ReadFunc := func;
end;


(* Generic - Computes the generic logical function specified by *)
(*           the function number "func" on the four input vars  *)
(*           a, b, c, and d.  It does this by returning bit     *)
(*           d*8 + c*4 + b*2 + a from func.  This version re-   *)
(*           lies on Turbo Pascal's shift right operator and    *)
(*           its ability to do bitwise operations on integers.  *)

function Generic(func,a,b,c,d:integer):integer;
begin
          Generic := (func shr (a + b*2 + c*4 + d*8)) and 1;
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