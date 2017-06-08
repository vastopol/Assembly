program PhotoFilter(input,output);

(* Here is the raw file data type produced by the Photoshop program *)

type
    image = array [0..250] of array [0..255] of byte;

(* The variables we will use.  Note that the "datain" and "dataout"     *)
(* variables are pointers because Turbo Pascal will not allow us to     *)
(* allocate more than 64K data in the one global data segment it        *)
(* supports.                                                            *)

var
    h,i,j,k,l,sum,iterations:integer;
    datain, dataout: ^image;
    f,g:file of image;

begin

     (* Open the files and real the input data  *)

     assign(f, 'roller1.raw');
     assign(g, 'roller2.raw');
     reset(f);
     rewrite(g);
     new(datain);
     new(dataout);
     read(f,datain^);

     (* Get the number of iterations from the user *)

     write('Enter number of iterations:');
     readln(iterations);

     writeln('Computing result');

     (* Copy the data from the input array to the output array. *)
     (* This is a really lame way to copy the border from the   *)
     (* input array to the output array.                        *)

     for i := 0 to 250 do
         for j := 0 to 255 do
             dataout^ [i][j] := datain^ [i][j];

     (* Okay, here's where all the work takes place.  The out-  *)
     (* side loop repeats this blurring operation the number of *)
     (* iterations specified by the user.                       *)

     for h := 1 to iterations do begin

       (* For each row except the first and the last, compute   *)
       (* a new value for each element.                         *)

       for i := 1 to 249 do

         (* For each column except the first and the last, com- *)
         (* pute a new value for each element.                  *)

         for j := 1 to 254 do begin

             (* For each element in the array, compute a new    *)
             (* blurred value by adding up the eight cells      *)
             (* around an array element along with eight times  *)
             (* the current cell's value.  Then divide this by  *)
             (* sixteen to compute a weighted average of the    *)
             (* nine cells forming a square around the current  *)
             (* cell.  The current cell has a 50% weighting,    *)
             (* the other eight cells around the current cell   *)
             (* provide the other 50% weighting (6.25% each).   *)

             sum := 0;
             for k := -1 to 1 do
                 for l := -1 to 1 do
                     sum := sum + datain^ [i+k][j+l];

             (* Sum currently contains the sum of the nine      *)
             (* cells, add in seven times the current cell so   *)
             (* we get a total of eight times the current cell. *)

             dataout^ [i][j] := (sum + datain^ [i][j]*7) div 16;

         end;

       (* Copy the output cell values back to the input cells   *)
       (* so we can perform the blurring on this new data on    *)
       (* the next iteration.                                   *)

       for i := 0 to 250 do
           for j := 0 to 255 do
               datain^ [i][j] := dataout^ [i][j];

     end;

     writeln('Writing result');
     write(g,dataout^);
     close(f);
     close(g);

end.


