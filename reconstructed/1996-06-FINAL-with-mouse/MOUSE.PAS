unit Mouse;

interface
uses crt,dos;
var
   regs:registers;

function  MouseExist:boolean;
procedure MouseOn;
procedure MouseOff;
function  MouseX:integer;
function  MouseY:integer;
function  Mouseln(a,b,c,d:integer):boolean;
function  MouseDown(n:byte):boolean;
procedure PutMouse(x,y:integer);
procedure LimitMouse(x1,y1,x2,y2:integer);
procedure graphicMouseCursor(xHotPoint,yHotPoint : byte; dataOfs : pointer);

procedure setWatchCursor;
procedure setNewWatchCursor;
procedure setUpArrowCursor;
procedure setLeftArrowCursor;
procedure setCheckMarkCursor;
procedure setPointingHandCursor;
procedure setDiagonalCrossCursor;
procedure setRectangularCrossCursor;
procedure setHourGlassCursor;
procedure setArrowCursor;

implementation

const watchData : array [0..31] of word =
	($E007,$C003,$8001,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$8001,$C003,$E007,
	 $0,$1FF8,$318C,$6186,$4012,$4022,$4042,$718C,$718C,$4062,$4032,
	 $4002,$6186,$318C,$1FF8,$0);

      arrowData : array [0..31] of word =
	($FFFF,$8FFF,$8FFF,$87FF,$83FF,$81FF,$80FF,$807F,$803F,$801F,$800F,
	 $801F,$807F,$887F,$DC3F,$FC3F,
	 $0,$0,$2000,$3000,$3800,$3C00,$3E00,$3F00,$3F80,$3FC0,
	 $3FE0,$3E00,$3300,$2300,$0180,$0180);

      UpArrowCursor : array [0..31] of word =
         ($f9ff,$f0ff,$e07f,$e07f,$c03f,$c03f,$801f,$801f,
          $f,$f,$f0ff,$f0ff,$f0ff,$f0ff,$f0ff,$f0ff,
          $0,$600,$f00,$f00,$1f80,$1f80,$3fc0,$3fc0,
          $7fe0,$600, $600, $600, $600, $600, $600, $600);

      LeftArrowCursor : array [0..31] of word
       = ($fe1f,$f01f,$0,   $0,   $0,   $f01f,$fe1f,$ffff,
          $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
          $0,   $c0,  $7c0, $7ffe,$7c0, $c0,  $0,   $0,
          $0,   $0,   $0,   $0,   $0,   $0,   $0,   $0);

      CheckMarkCursor : array [0..31] of word
       = ($fff0,$ffe0,$ffc0,$ff81,$ff03,$607, $f,   $1f,
          $c03f,$f07f,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
          $0,   $6,   $c,   $18,  $30,  $60,  $70c0,$1d80,
          $700, $0,   $0,   $0,   $0,   $0,   $0,   $0);

      PointingHandCursor : array [0..31] of word
       = ($e1ff,$e1ff,$e1ff,$e1ff,$e1ff,$e000,$e000,$e000,
          $0,   $0,   $0,   $0,   $0,   $0,   $0,   $0,
          $0000,$0C00,$0C00,$0C00,$0C00,$0C00,$0DB6,$0DB6,
          $0DB6,$6FFE,$6FFE,$6FFE,$7FFE,$7FFE,$7FFE,$0000);

      DiagonalcrossCursor : array [0..31] of word
       = ($7e0, $180, $0,   $c003,$f00f,$c003,$0,   $180,
          $7e0, $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
          $0,   $700e,$1c38,$660, $3c0, $660, $1c38,$700e,
          $0,   $0,   $0,   $0,   $0,   $0,   $0,   $0);

      RectangularCrossCursor : array [0..31] of word
       = ($fc3f,$fc3f,$fc3f,$0,$0,   $0,   $fc3f,$fc3f,
          $fc3f,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
          $0,   $180, $180, $180, $7ffe,$180, $180, $180,
          $0,   $0,   $0,   $0,   $0,   $0,   $0,   $0);

      HourglassCursor : array [0..31] of word
       = ($0,   $0,   $0,   $0,   $8001,$c003,$e007,$f00f,
          $e007,$c003,$8001,$0,   $0,   $0,   $0,   $ffff,
          $0,   $7ffe,$6006,$300c,$1818,$c30, $660, $3c0,
          $660, $c30, $1998,$33cc,$67e6,$7ffe,$0,   $0);

      newWatchCursor : array [0..31] of word
       = ( $ffff, $c003, $8001, $0, $0, $0, $0, $0, $0,
           $0, $0, $0, $0, $8001, $c003, $ffff, $0, $0,
           $1ff8, $2004, $4992, $4022, $4042, $518a, $4782,
           $4002, $4992, $4002, $2004, $1ff8, $0, $0 );

procedure Callmouse;
begin
     intr(51,regs);
end;

function MouseExist:boolean;
var aux:boolean;
begin
     aux:=directVideo;
     directVideo:=false;
     regs.ax:=0;
     callmouse;
     mouseExist:=(regs.ax=0);
     directVideo:=aux;
end;

procedure MouseOn;
begin
     regs.ax:=1;
     callmouse;
end;

procedure MouseOff;
begin
     regs.ax:=2;
     callmouse;
end;

function Mousex:integer;
begin
     regs.ax:=3;
     callmouse;
     Mousex:=regs.cx;
end;

function Mousey:integer;
begin
     regs.ax:=3;
     callmouse;
     Mousey:=regs.dx;
end;

function Mouseln(a,b,c,d:integer):boolean;
begin
     regs.ax:=3;
     callmouse;
     Mouseln:=((regs.cx>a) and (regs.cx<c)) and ((regs.dx>b) and (regs.dx<d));
end;

function MouseDown(n:byte):boolean;
begin
     regs.ax:=3;
     callmouse;
     MouseDown:=(n=regs.bx);
end;

procedure PutMouse(x,y:integer);
begin
     regs.ax:=9;
     regs.bx:=x;
     regs.cx:=y;
end;

procedure LimitMouse(x1,y1,x2,y2:integer);
begin
     regs.ax:=7;
     regs.cx:=x1;
     regs.dx:=x2;
     callmouse;
     regs.ax:=8;
     regs.cx:=y1;
     regs.dx:=y2;
     callmouse;
end;

procedure graphicMouseCursor(xHotPoint,yHotPoint : byte; dataOfs : pointer);
begin
	regs.ax := 9;
	regs.bx := xHotPoint;
	regs.cx := yHotPoint;
	regs.dx := ofs(dataOfs^);	{DS:DX point to masks}
	regs.es := seg(dataOfs^);
	callMouse;
end;

procedure setWatchCursor;
begin
   graphicMouseCursor(0,0,@watchData);
end;

procedure setNewWatchCursor;
begin
   graphicMouseCursor(0, 0, @newWatchCursor);
end;

procedure setUpArrowCursor;
begin
	graphicMouseCursor(5, 0, @upArrowCursor);
end;

procedure setLeftArrowCursor;
begin
	graphicMouseCursor(0, 3, @leftArrowCursor);
end;

procedure setCheckMarkCursor;
begin
	graphicMouseCursor(6, 7, @checkMarkCursor);
end;

procedure setPointingHandCursor;
begin
	graphicMouseCursor(5, 0, @pointingHandCursor);
end;

procedure setDiagonalCrossCursor;
begin
	graphicMouseCursor(7, 4, @diagonalCrossCursor);
end;

procedure setRectangularCrossCursor;
begin
	graphicMouseCursor(7, 4, @rectangularCrossCursor);
end;

procedure setHourGlassCursor;
begin
	graphicMouseCursor(7, 7, @hourGlassCursor);
end;

procedure setArrowCursor;
begin
	graphicMouseCursor(1,1,@arrowData);
end;
end.