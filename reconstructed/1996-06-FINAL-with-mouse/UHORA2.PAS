{********************************************************************}
{ Unidad UHORA2.PAS                           				    }
{ Unidad de procesamiento del archivo HORARIO.PAS  Manejo de Texto.  }
{			  	                    		   (C) 1995 - 1996 }
{********************************************************************}
unit uhora2;

INTERFACE

uses crt;

procedure beep;

function space(num:integer):string;
function trim(cad:string):string;
function upper(cad:string):string;
function ltrim(cad:string):string;
function rtrim(cad:string):string;
function alltrim(cad:string):string;
function numval(text:string):real;
function strval(num:real):string;
function left(text:string; cant:integer):string;
function right(text:string; cant:integer):string;

IMPLEMENTATION

procedure beep;

begin
     sound(200);
     delay(30);
     nosound;
end;

function space;
var i:integer;
    temp:string;

begin
     temp:='';
     for i:=1 to num do temp:=temp+' ';
     space:=temp;
end;

function upper; {devuelve toda la cadena en may£sculas}
var i:integer;

begin
     for i:=1 to length(cad) do cad[i]:=upcase(cad[i]);
     upper:=cad;
end;

function ltrim; {borra espacios en blanco a la izquierda}
var i:integer;

begin
     i:=0;
     while cad[i+1]=' ' do inc(i);
     ltrim:=copy(cad,i+1,length(cad)-i);
end;

function rtrim; {borra espacios en blanco a la derecha}
var i:integer;

begin
     i:=length(cad);
     while cad[i]=' ' do dec(i);
     rtrim:=copy(cad,1,i);
end;

function alltrim;

begin
     alltrim:=ltrim(rtrim(cad));
end;

function trim;
begin
     trim:=upper(alltrim(cad));
end;

function numval;
var  code:integer;
     num:real;

begin
     val(text,num,code);
     numval:=num;
end;

function strval(num:real):string;
var  text:string;

begin
     str(num:0:0,text);
     strval:=text;
end;

function left;

begin
     left:=copy(text,1,length(text)-cant+1);
end;

function right;

begin
     right:=copy(text,length(text)-cant+1,cant);
end;

end.