unit Patterns;

interface

type

  TPatPtr  = ^TPattern;

  mType = record case integer of

  	0: (ch:char);
        1:(str:PChar);
        2:(cset:set of char);
        3:(pat:TPatPtr);
        4:(index:word);

  end;

  TPattern = record

        mf:function(Pat:TPatPtr):boolean;
        m:mType;
        Next:TPatPtr;
        Alt:TPatPtr;
        success:procedure(Pat:TPatPtr);
	EndPattern:PChar;
        StartPattern:PChar;

  end;


 function match(var Pattern:TPattern; var str:PChar):boolean;

 function SpanCset(Pat:TPatPtr):Boolean;
 function AnyCset(Pat:TPatPtr):Boolean;
 function OneOrMoreCset(Pat:TPatPtr):Boolean;
 function BrkCset(Pat:TPatPtr):Boolean;
 function NotAnyCset(Pat:TPatPtr):Boolean;
 function MatchStr(Pat:TPatPtr):Boolean;
 function MatchiStr(Pat:TPatPtr):Boolean;
 function MatchChar(Pat:TPatPtr):Boolean;
 function MatchChars(Pat:TPatPtr):Boolean;
 function MatchToChar(Pat:TPatPtr):Boolean;
 function MatchToPat(Pat:TPatPtr):Boolean;
 function ARB(Pat:TPatPtr):Boolean;
 function ARBNUM(Pat:TPatPtr):Boolean;
 function EOS(Pat:TPatPtr):Boolean;
 function skip(Pat:TPatPtr):Boolean;
 function pos(Pat:TPatPtr):Boolean;
 function MatchSub(Pat:TPatPtr):Boolean;
 function Succeed(Pat:TPatPtr):Boolean;


implementation

uses SysUtils;

function match(var Pattern:TPattern; var str:PChar):boolean;
begin

	Pattern.StartPattern := str;
        Pattern.EndPattern := str;

        { See if the current pattern matches anything at the	}
        { beginning of the current string.			}

        if (Pattern.mf(@Pattern)) then
        begin

             { If we got a match, see if there is a follow-on	}
             { pattern and try to match it, if so;  If no such	}
             { pattern, return success.				}

             if (Pattern.Next <> NIL) then
             begin

        	Result := match(Pattern.Next^, Pattern.EndPattern);
                if Result then
                   Pattern.EndPattern := Pattern.Next^.EndPattern;

             end
             else Result := true;

             { If we've got a successful match, and "success" points	}
             { at a procedure, execute that procedure.		        }

             if Result and (@Pattern.Success <> NIL) then
        	Pattern.Success(@Pattern);

        end

        { If the pattern did not match, look for an alternate	}
        { pattern and try to match it if it exists.  Return	}
        { failure if there is no alternate pattern.		}

        else if (Pattern.Alt <> NIL) then
        begin

        	Result := match(Pattern.Alt^, Pattern.EndPattern);
                if (Result) then
                   Pattern.EndPattern := Pattern.Alt^.EndPattern;
        end
        else Result := false;


end;


function MatchSub(Pat:TPatPtr):Boolean;
begin


        Result := Match(Pat^.m.Pat^, Pat^.EndPattern);
        if (Result) then Pat^.EndPattern := Pat^.m.Pat^.EndPattern;

end;


{ Succeed- Always Succeeds                                         }

function Succeed(Pat:TPatPtr):Boolean;
begin

        Result := true;

end;
{ SpanCset- This matching function skips over any characters	}
{	    found in the cset field.				}

function SpanCset(Pat:TPatPtr):Boolean;
begin

	while (Pat^.EndPattern^ in Pat^.m.cset) do inc(Pat^.EndPattern);
        Result := true;

end;


{ AnyCset-  This matching function skips over a single character}
{	    found in the cset field.				}

function AnyCset(Pat:TPatPtr):Boolean;
begin

	Result := Pat^.EndPattern^ in Pat^.m.cset;
        if Result then inc(Pat^.EndPattern);

end;


{ OneOrMoreCset- This matching function skips over any chars	}
{	    found in the cset field. there must be at least	}
{           one character for this to succeed.                  }

function OneOrMoreCset(Pat:TPatPtr):Boolean;
begin

	Result := Pat^.EndPattern^ in Pat^.m.cset;
        if Result then
        begin

             inc(Pat^.EndPattern);
	     while (Pat^.EndPattern^ in Pat^.m.cset) do
                   inc(Pat^.EndPattern);
        end;

end;

{ BrkCset- This matching function skips over any characters	}
{	   that are not in the cset field.			}

function BrkCset(Pat:TPatPtr):Boolean;
begin

	while  (Pat^.EndPattern^ <> #0) and
        	not (Pat^.EndPattern^ in Pat^.m.cset) do
                   inc(Pat^.EndPattern);
        Result := true;

end;

{ NotAnyCset- This matching function skips over a single	}
{	      character that is not in the cset field.		}

function NotAnyCset(Pat:TPatPtr):Boolean;
begin

	Result := (Pat^.EndPattern^ = #0) or
        	not (Pat^.EndPattern^ in Pat^.m.cset);
        if (Result) then inc(Pat^.EndPattern);

end;

{ MatchStr- Skips over the characters that match a string.	}

function MatchStr(Pat:TPatPtr):Boolean;

    function MatchPrefix(var s:PChar; t:PChar):Boolean;
    var tmp:PChar;
    begin

    	tmp := s;
        while (tmp^ = t^) and (t^ <> #0) do
        begin

        	inc(tmp);
                inc(t);

        end;
        Result := t^ = #0;
        if (Result) then s := tmp;

    end;

begin

	Result :=MatchPrefix(Pat^.EndPattern, Pat^.m.str);

end;


{ MatchiStr-	Skips over the characters that match a string,	}
{		ignoring case.					}

function MatchiStr(Pat:TPatPtr):Boolean;

    function MatchPrefix(var s:PChar; t:PChar):Boolean;
    var tmp:PChar;
    begin

    	tmp := s;
        while (upcase(tmp^) = upcase(t^)) and (t^ <> #0) do
        begin

        	inc(tmp);
                inc(t);

        end;
        Result := t^ = #0;
        if (Result) then s := tmp;

    end;

begin

	Result :=MatchPrefix(Pat^.EndPattern, Pat^.m.str);

end;


{ MatchToStr-	This function scans through the string to see	}
{		if it can match some string at the current	}
{		character or later in the string.		}
{		This is a truly disgusting algorithm.		}
{		Need to clean this one up some day.		}

function MatchToStr(Pat:TPatPtr):Boolean;
var tmp:PChar;
begin

    with Pat^ do
    begin

    	tmp := EndPattern;
    	while (EndPattern^ <> #0) and
    	      not MatchStr(Pat) do inc(EndPattern);

        Result := EndPattern^ <> #0;
        if not Result then EndPattern := tmp;

    end;

end;



{ MatchChar-	Matches a single character in the string.	}

function MatchChar(Pat:TPatPtr):Boolean;
begin

	Result := Pat^.EndPattern^ = Pat^.m.ch;
        if Result then inc(Pat^.EndPattern);

end;

{ MatchChars-	Matches zero or more occurrences of a char-	}
{		acter in the string.				}

function MatchChars(Pat:TPatPtr):Boolean;
begin

	while (Pat^.EndPattern^ = Pat^.m.ch) do inc(Pat^.EndPattern);
        Result := true;

end;


{ MatchToChar-	Matches all characters in a string up to a	}
{		specified character.  Fails if that character	}
{		is not in the string.				}

function MatchToChar(Pat:TPatPtr):Boolean;
var tmp:PChar;
begin

	tmp := Pat^.EndPattern;
        while (tmp^ <> #0) and (tmp^ <> Pat^.m.ch) do
        	inc (tmp);

        Result := tmp^ = Pat^.m.ch;
        if (Result) then Pat^.EndPattern := tmp;

end;



{ MatchToPat-	Matches all characters in a string up to a	}
{		specified pattern.  This algorithm is a "shy"	}
{		algorithm insofar is it will match as few chars	}
{		as possible before matching the pattern.	}
{		Also see ARB.					}

function MatchToPat(Pat:TPatPtr):Boolean;
var tmp:PChar;
begin

	tmp := Pat^.EndPattern;
        repeat

        	Result := match(Pat^.m.pat^, tmp);
                if (not Result and (tmp^ <> #0)) then inc(tmp);

        until Result or (tmp^ = #0);
        if (Result) then Pat^.EndPattern := tmp;

end;


{ ARB-		Matches all characters in a string up to a	}
{		specified pattern.  This algorithm is a greedy	}
{		algorithm insofar is it will match as many chars}
{		as possible before matching the pattern.	}
{		Also see MatchToPat.				}

function ARB(Pat:TPatPtr):Boolean;
var tmp:PChar;
begin

	tmp := Pat^.EndPattern;
        tmp := tmp + strlen(tmp);
        repeat

        	Result := match(Pat^.m.pat^, tmp);
                if (not Result and (tmp <> Pat^.EndPattern)) then dec(tmp);

        until Result or (tmp = Pat^.EndPattern);
        if (Result) then Pat^.EndPattern := Pat^.m.pat^.EndPattern;

end;


{ ARBNUM-	Matches an arbitrary number of strings matching	}
{		the parameter pattern.				}

function ARBNUM(Pat:TPatPtr):Boolean;
begin

        while (match(Pat^.m.pat^, Pat^.EndPattern)) do
        	Pat^.EndPattern := Pat^.m.pat^.EndPattern;
        Result := true;

end;

{ EOS-		Matches the end of string character (#0).	}

function EOS(Pat:TPatPtr):Boolean;
begin

	Result := Pat^.EndPattern^ = #0;

end;


{ Skip-		Skips over "index" characters in the string if	}
{		there are that many characters left in the str.	}

function skip(Pat:TPatPtr):Boolean;
var 	LastPosn,
	save	:PChar;
begin

        with Pat^ do begin

            save := EndPattern;
            LastPosn := EndPattern + m.index;
            while (EndPattern^ <> #0) and (EndPattern < LastPosn) do
            	inc(EndPattern);

            Result := EndPattern^ <> #0;
            if not Result then EndPattern := save;

        end;
end;


{ Pos-		Returns true if the pattern matching algorithm	}
{		is currently processing the character at pos-	}
{		ition "index" in the string.			}

function pos(Pat:TPatPtr):Boolean;
begin

    with Pat^ do begin

	Result := (EndPattern - StartPattern) = m.index;

    end;
end;





end.
