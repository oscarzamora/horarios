{********************************************************************}
{ Unidad UHORA2.PAS                           				    }
{ Unidad de procesamiento del archivo HORARIO.PAS  Manejo de Texto.  }
{			  	                    				(C) 1995 }
{********************************************************************}
unit uhora2;

INTERFACE

uses crt;

procedure beep;

function space(num:integer):string;
function upper(frase:string):string;
function ltrim(cad:string):string;
function rtrim(cad:string):string;
function alltrim(cad:string):string;
function numval(text:string):real;
function strval(num:real):string;

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
     for i:=1 to length(frase) do frase[i]:=upcase(frase[i]);
     upper:=frase;
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

end.