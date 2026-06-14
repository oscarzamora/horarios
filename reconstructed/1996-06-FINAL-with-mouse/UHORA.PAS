{********************************************************************}
{ Unidad UHORA.PAS                                                   }
{ Unidad de procesamiento del programa HORARIO.PAS. Modo gr fico.    }
{                                                                    }
{                            Copyright (C) ZmS Software, 1995 - 1996 }
{                                                                    }
{ NOTA DE RECONSTRUCCION (2026): version 1.2 con soporte para mouse. }
{ El fuente original de junio 1996 se perdio; solo sobrevive el      }
{ binario HORARIOS.EXE (44820 bytes, 01-JUN-1996). Esta unidad es    }
{ una re-implementacion a partir de UHORA.PAS 1.1 (HORA11, ABR-1996) }
{ integrando la unit MOUSE.PAS que estuvo presente, sin uso, en      }
{ todas las distribuciones de fuentes desde 1995. No es              }
{ decompilacion: misma API, mismo estilo, click adicional al teclado.}
{********************************************************************}

unit uhora;

INTERFACE
uses crt,graph,uhora2,mouse;
type tpitem=array[0..375] of string[30];
     tpindex=array[0..375] of boolean;
var	p:pointer; {puntero para captura de im genes}
     hasMouse:boolean;

procedure selectitem(title:string; cant:integer; maxindex:integer; item:tpitem; var index:tpindex);
procedure ventcls(x1,y1,x2,y2,fon,col:integer; tit:string);
procedure ventana(x1,y1,x2,y2,fondo,coltit:integer; titulo:string);
procedure buton(x,y,long,wide:integer; selec:byte; cad:string);
procedure gettext(wintitle:string; tot:integer; max:array of byte;
		title:array of string; var out:array of string);
procedure clsout;
procedure getimg(x1,y1,x2,y2:word);
procedure putimg(x1,y1,x2,y2:word);

{ --- Soporte para mouse (reconstruccion 1.2) -------------------------- }
{ Se llama una sola vez despues de Initgraph para detectar el raton y   }
{ fijar los limites a la pantalla grafica. Si no hay raton, hasMouse    }
{ queda en false y todo el resto de la unit sigue funcionando solo con  }
{ teclado, como en 1.1.                                                 }
procedure initMouseSupport;
procedure showMouse;
procedure hideMouse;
{ Devuelve true si el boton izquierdo del raton esta presionado dentro  }
{ del rectangulo (x1,y1)-(x2,y2). Cuando devuelve true espera a que el  }
{ usuario suelte el boton para que el mismo click no se procese dos     }
{ veces en bucles sucesivos. Si no hay raton devuelve false.            }
function  mouseHit(x1,y1,x2,y2:integer):boolean;
{ ---------------------------------------------------------------------- }

function msgbox(title:string; selec,cant:byte; texts:array of string):boolean;

IMPLEMENTATION

{ --- Soporte para mouse (reconstruccion 1.2) -------------------------- }

procedure initMouseSupport;
begin
     hasMouse:=MouseExist;
     if hasMouse then begin
        LimitMouse(0,0,getmaxx,getmaxy);
        MouseOn;
     end;
end;

procedure showMouse;
begin
     if hasMouse then MouseOn;
end;

procedure hideMouse;
begin
     if hasMouse then MouseOff;
end;

function mouseHit(x1,y1,x2,y2:integer):boolean;
begin
     mouseHit:=false;
     if not hasMouse then exit;
     if not MouseDown(1) then exit;
     if not Mouseln(x1,y1,x2,y2) then exit;
     mouseHit:=true;
     { espera al unclick para no procesar el mismo click dos veces }
     while MouseDown(1) do ;
end;

{ ---------------------------------------------------------------------- }

procedure ventana;
{Procedimiento que imprime en pantalla una ventana seg£n las coordenadas
que se manden, el color del fondo, el color de la barra de t¡tulo y el
t¡tulo.}

begin
     setlinestyle(0,0,0);
     setfillstyle(1,7);{definici¢n de borde inicial}
     bar(x1,y1,x2,y2);
     setcolor(0);
     rectangle(x1,y1,x2,y2);
     rectangle(x1+3,y1+3,x2-3,y2-3);
     line(x1+4,y1+22,x2-4,y1+22);
     ventcls(x1,y1,x2,y2,fondo,coltit,titulo);
end;

procedure ventcls;
{Procedimiento que limpia el contenido de la ventana con las coordenadas
que se manden. No definde los bordes de las ventanas.}

begin
     settextstyle(0,0,1);
     setfillstyle(1,fon);
     bar(x1+4,y1+23,x2-4,y2-4);
	setfillstyle(1,col);
     bar(x1+4,y1+4,x2-4,y1+21);
     setcolor(15);
     outtextxy(round((x2-x1)/2)+x1-round(textwidth(tit)/2),y1+9,tit);
end;

procedure buton;
{Procedimiento que imprime botones seg£n las coordenadas que se manden,
el ancho, el alto y el contenido del mismo. Los estados son: 0 = impresi¢n
normal del bot¢n, 1 = selecci¢n del bot¢n, imprimiendo un rect ngulo
punteado encerrando el texto, 2 = bot¢n persionado, 3 = borra la selecci¢n
del bot¢n (elimina el rect ngulo punteado).}

var thw,thh:integer;

begin
     thw:=round(Textwidth(cad)/2);
     thh:=round(Textheight(cad)/2);

     if (selec<>1) and (selec<>3) then begin
        {definici¢n de bordes para relleno}
        setcolor(0);
        setlinestyle(0,0,0);
        line(x+4,y+wide,x+long-4,y+wide);
        line(x+long,y+4,x+long,y+wide-4);
        line(x+4,y,x+long-4,y);
        line(x,y+4,x,y+wide-4);
        arc(x+3,y+3, 90, 180, 3); {izq. sup.}
        arc(x+3,y+wide-3, 180, 270, 3); {izq. inf.}
        arc(x+long-3,y+3, 0, 90, 3); {der. sup.}
        arc(x+long-3,y+wide-3, 270, 0, 3); {der. inf.}

        rectangle(x+3,y+3,x+long-3,y+wide-3);
        line(x+3,y+wide-3,x+2,y+wide-2);
        line(x+long-3,y+3,x+long-2,y+2);
     end;

     case selec of
          0:begin
                 SetFillStyle(1,15);
                 FloodFill(x+4,y+1,0);
                 SetFillStyle(1,8);
                 FloodFill(x+4,y+wide-2,0);
                 SetFillStyle(1,7);
                 bar(x+3,y+3,x+long-3,y+wide-3);
                 setcolor(0);
                 outtextxy(x+round(long/2)-thw,y+round(wide/2)-thh,cad);
          end;
          1:begin
			setcolor(0);
			setlinestyle(1,0,0);
			rectangle(x+round((long-thw*2)/2)-3,y+round((wide-thh*2)/2)-3,
			x+long-round((long-thw*2)/2)+2,y+wide-round((wide-thh*2)/2)+2);
             end;
		2:begin
			SetFillStyle(1,7);
			FloodFill(x+4,y+wide-2,0);
			SetFillStyle(1,8);
			FloodFill(x+4,y+2,0);
			SetFillStyle(1,7);
			bar(x+3,y+3,x+long-3,y+wide-3);
			setcolor(0);
			outtextxy(x+round(long/2)-thw+2,y+round(wide/2)-thh+2,cad);
			setlinestyle(1,0,0);
			rectangle(x+round((long-thw*2)/2)-1,y+round((wide-thh*2)/2)-1,
			x+long-round((long-thw*2)/2)+4,y+wide-round((wide-thh*2)/2)+4);
             end;
          3:begin
			setcolor(7);
			setlinestyle(0,0,0);
			rectangle(x+round((long-thw*2)/2)-3,y+round((wide-thh*2)/2)-3,
			x+long-round((long-thw*2)/2)+2,y+wide-round((wide-thh*2)/2)+2);
          end;
     end;
     setlinestyle(0,0,0);
end;

procedure gettext;

var xt,len,k,l,num,i,x,y,x1,x2,y1,y2:integer;
    text,frase:string;
    ins:byte;
    key:char;
    fieldClicked:integer; { reconstruccion 1.2 }

begin
     settextstyle(0,0,1);
     ins:=0;
	num:=0;
     k:=textwidth(' ');
     l:=textheight(' ');
	x1:=round(getmaxx/2)-round(k/2*(max[0]+length(title[0])+5));
	x2:=round(getmaxx/2)+round(k/2*(max[0]+length(title[0])+5));
     if x1>150 then x1:=150;
     if x2<490 then x2:=490;
     y1:=round(getmaxy/2)-round(tot*l*1.75/2+30);
     y2:=round(getmaxy/2)+round(tot*l*1.7+50);
     getimg(x1,y1,x2,y2);
     settextstyle(0,0,1);
     ventana(x1,y1,x2,y2,7,9,wintitle);
     buton(x1+50,y2-35,100,25,0,'OK');
     buton(x2-150,y2-35,100,25,0,'Cancelar');

     setfillstyle(1,15);
     for i:=0 to tot-1 do begin
     	setcolor(1);
          y:=y1+35+20*i;
     	outtextxy(x1+2*k,y,title[i]);
     	x:=x1+textwidth(title[i])+3*k;
          bar(x-2,y-2,x+max[i]*k+2,y+l+2);
          setcolor(0);
          outtextxy(x,y,out[i]);
	     rectangle(x-3,y-3,x+max[i]*k+3,y+l+3);
	     setcolor(8);
		rectangle(x-4,y-4,x+max[i]*k+4,y+l+4);
	     setcolor(15);
		line(x-3,y+l+4,x+max[i]*k+4,y+l+4);
	     line(x+max[i]*k+4,y-3,x+max[i]*k+4,y+l+4);
     end;

repeat
     buton(x1+50,y2-35,100,25,3,'OK');
     buton(x2-150,y2-35,100,25,3,'Cancelar');
     text:=out[num];
     if length(text)<max[num] then xt:=length(text)+1 else xt:=max[num];
     repeat
	     setcolor(0);
     	x:=x1+textwidth(title[num])+3*k;
     	y:=y1+35+20*num;
		bar(x-2,y-2,x+max[num]*k+2,y+l+2);
          outtextxy(x,y,text);
          setcolor(7);
          if ins=1 then outtextxy(x+k*(xt-1),y,'Û')
			else outtextxy(x+k*(xt-1),y,'_');
          setcolor(0);
          if xt<=length(text) then outtextxy(x+k*(xt-1),y,text[xt]);

          { polling: tecla o click en campo / OK / Cancelar (reconstruccion 1.2) }
          key:=#1; { centinela: click manejado in-place sin generar tecla }
          repeat
               if keypressed then begin
                    key:=readkey;
                    if key<>'' then break;
               end;
               if mouseHit(x1+50,y2-35,x1+150,y2-10) then begin
                    key:=#13; break;
               end;
               if mouseHit(x2-150,y2-35,x2-50,y2-10) then begin
                    key:=#27; break;
               end;
               if hasMouse and MouseDown(1) then begin
                    fieldClicked:=-1;
                    i:=0;
                    while i<tot do begin
                         if Mouseln(x1+textwidth(title[i])+3*k-3,
                                    y1+35+20*i-3,
                                    x1+textwidth(title[i])+3*k+max[i]*k+3,
                                    y1+35+20*i+l+3) then begin
                              fieldClicked:=i;
                              break;
                         end;
                         inc(i);
                    end;
                    while MouseDown(1) do ;
                    if fieldClicked>=0 then begin
                         { commit del campo actual y salto al clickeado }
                         bar(x-2,y-2,x+max[num]*k+2,y+l+2);
                         outtextxy(x,y,text);
                         out[num]:=text;
                         num:=fieldClicked;
                         text:=out[num];
                         if length(text)<max[num] then xt:=length(text)+1
							else xt:=max[num];
                         break; { sale del polling con key=#1: case no dispara, loop redibuja }
                    end;
               end;
          until false;

          case key of
          	#8:if xt>1 then begin
               	delete(text,xt-1,1);
                    dec(xt);
               end;
               #13:begin
                    out[num]:=text;
			     putimg(x1,y1,x2,y2);
                    exit;
               end;
               #9:begin
               	bar(x-2,y-2,x+max[num]*k+2,y+l+2);
                    outtextxy(x,y,text);
                    out[num]:=text;
                    inc(num); text:=out[num];
                    if length(text)<max[num] then xt:=length(text)+1
					else xt:=max[num];
               end;
               #27:begin
               	putimg(x1,y1,x2,y2);
               	out[0]:=#27;
                    exit;
               end;
               #127:begin
               	text:='';
                    xt:=1;
               end;

               #0:begin
               	key:=readkey;
                    case key of
                    	#15:begin
               			bar(x-2,y-2,x+max[num]*k+2,y+l+2);
                    		outtextxy(x,y,text);
                    		out[num]:=text;
                    		if num=0 then begin
							num:=tot+1; end
						else begin
							dec(num); text:=out[num];
                              	if length(text)<max[num]
								then xt:=length(text)+1
									 else xt:=max[num];
                              end;
                         end;
                         #75:if xt>1 then dec(xt);
                         #77:if (xt<>max[num]) and (xt<=length(text))
						then inc(xt);
                         #83:if xt<=length(text) then delete(text,xt,1);
                         #71:xt:=1;
                         #79:begin
                         	xt:=length(text)+1;
                              if length(text)=max[num] then dec(xt);
                         end;
                         #82:if ins=0 then ins:=1 else ins:=0;
                    end;
               end;
			else begin
          		if ins=0 then begin
               		if xt=max[num] then begin
                    		if max[num]=length(text)+1 then begin
                         		text:=text+key; end
                         	else begin
                         		delete(text,xt,1);
                              	insert(key,text,xt);
                         	end; end
                    	else begin
                    		if length(text)<max[num] then begin
                         		insert(key,text,xt);
                              	inc(xt); end
                    		else begin
                         		delete(text,xt,1);
                         		insert(key,text,xt);
                         	end;
                    	end; end
               	else begin
               		delete(text,xt,1);
                    	insert(key,text,xt);
                    	if xt<max[num] then inc(xt);
               	end;
          	end;
     	end;
     until num>tot-1;
     while num>tot-1 do begin
     	if num=tot then begin
			buton(x1+50,y2-35,100,25,1,'OK');
		     buton(x2-150,y2-35,100,25,3,'Cancelar'); end
	     else begin
			buton(x1+50,y2-35,100,25,3,'OK');
		     buton(x2-150,y2-35,100,25,1,'Cancelar');
	     end;
     	{ polling: tecla o click (reconstruccion 1.2) }
     	key:=#1;
     	repeat
               if keypressed then begin
                    key:=readkey;
                    if key<>'' then break;
               end;
               if mouseHit(x1+50,y2-35,x1+150,y2-10) then begin
                    num:=tot; key:=#13; break;
               end;
               if mouseHit(x2-150,y2-35,x2-50,y2-10) then begin
                    num:=tot+1; key:=#13; break;
               end;
               if hasMouse and MouseDown(1) then begin
                    fieldClicked:=-1;
                    i:=0;
                    while i<tot do begin
                         if Mouseln(x1+textwidth(title[i])+3*k-3,
                                    y1+35+20*i-3,
                                    x1+textwidth(title[i])+3*k+max[i]*k+3,
                                    y1+35+20*i+l+3) then begin
                              fieldClicked:=i;
                              break;
                         end;
                         inc(i);
                    end;
                    while MouseDown(1) do ;
                    if fieldClicked>=0 then begin
                         num:=fieldClicked;
                         break; { sale del while exterior, re-entra al modo edicion }
                    end;
               end;
     	until false;
     	case key of
          	#9:if num<tot+1 then inc(num) else num:=0;
     		#27:begin
     			putimg(x1,y1,x2,y2);
               	out[0]:=#27;
                    exit;
               end;
               #13,#32:case num-tot of
               	0:begin
                    	buton(x1+50,y2-35,100,25,2,'OK');
                         delay(250);
     				putimg(x1,y1,x2,y2);
                    	exit;
                    end;
                    1:begin
					buton(x2-150,y2-35,100,25,2,'Cancelar');
                         delay(250);
     				putimg(x1,y1,x2,y2);
               		out[0]:=#27;
                    	exit;
                    end;
                   end;
               #0:begin key:=readkey;
               	if key=#15 then dec(num);
               end;
          end;
     end;
until false;
end;

function msgbox;

var key:char;
    i,x1,y1,x2,y2:integer;
    sel:byte;
    b1,b2:string;

begin
	settextstyle(0,0,1);
	b1:='OK';
     b2:='Cancelar';
	sel:=1;
     msgbox:=true;
     x1:=getmaxx-490; x2:=getmaxx-150;
     y1:=round(getmaxy/2)-round(cant*textheight(texts[0])*1.75/2+30);
     y2:=round(getmaxy/2)+round(cant*textheight(texts[0])*1.75/2+60);
     getimg(x1,y1,x2,y2);
     ventana(x1,y1,x2,y2,15,3,title);
     setcolor(0);
     settextstyle(0,0,1);
     for i:=1 to cant do begin
         outtextxy(round(getmaxx/2)-round(textwidth(texts[i-1])/2),y1+20+
         round(textheight(texts[i-1])*i*1.75),texts[i-1]);
     end;
     if selec=0 then buton(round(getmaxx/2)-50,y2-45,100,25,0,b1) else begin
     	buton(x1+30,y2-45,100,25,0,b1);
          buton(x2-130,y2-45,100,25,0,b2);
     end;
     repeat
     	if selec=0 then buton(round(getmaxx/2)-50,y2-45,100,25,1,b1)
			else begin
     		buton(x1+30,y2-45,100,25,3,b1);
          	buton(x2-130,y2-45,100,25,3,b2);
			case sel of
               	1:buton(x1+30,y2-45,100,25,1,b1);
                    2:buton(x2-130,y2-45,100,25,1,b2);
			end;
          end;
          { polling: tecla o click sobre boton (reconstruccion 1.2) }
          key:=#1; { centinela }
          repeat
               if keypressed then begin
                    key:=readkey;
                    break;
               end;
               if selec=0 then begin
                    if mouseHit(round(getmaxx/2)-50,y2-45,round(getmaxx/2)+50,y2-20) then begin
                         key:=#13;
                         break;
                    end;
               end else begin
                    if mouseHit(x1+30,y2-45,x1+130,y2-20) then begin
                         sel:=1; key:=#13; break;
                    end;
                    if mouseHit(x2-130,y2-45,x2-30,y2-20) then begin
                         sel:=2; key:=#13; break;
                    end;
               end;
          until false;
          case key of
          	#13,#32:if selec=0 then
				buton(round(getmaxx/2)-50,y2-45,100,25,2,b1) else
               	case sel of
                    	1:buton(x1+30,y2-45,100,25,2,b1);
                         2:begin
						buton(x2-130,y2-45,100,25,2,b2);
                              msgbox:=false;
                         end;
                    end;
               #9:if sel=1 then sel:=2 else sel:=1;
               #27:msgbox:=false;
               #0:begin key:=readkey;
                    if key=#15 then if sel=1 then sel:=2 else sel:=1;
               end;
          end;
     until ((key=#27) and (selec<>0)) or (key=#13) or (key=#32);
     delay(200);
     putimg(x1,y1,x2,y2);
end;

procedure selectitem;
var b1,b2:string;
    sel,antsel,extsel,antextsel,i,selec,sumselec:integer;
    x1,x2,y1,y2:integer;
    key:char;
    scrollDone:boolean;     { reconstruccion 1.2 }
    trackH,target:integer;  { reconstruccion 1.2 }

begin
     index[0]:=false;
     sumselec:=0;
     for i:=1 to cant do if index[i]=true then inc(sumselec);
	settextstyle(0,0,1);
	b1:='OK';
     b2:='Cancelar';
     extsel:=0;
     antextsel:=1;
	sel:=1;
     antsel:=1;
     selec:=0;
     x1:=getmaxx-480; x2:=getmaxx-160;
     y1:=getmaxy-380; y2:=getmaxy-80;
     getimg(x1,y1,x2,y2);
     ventana(x1,y1,x2,y2,15,1,title);
     setcolor(0);
     rectangle(x1+25,y1+35,x2-25,y2-60);
     line(x2-40,y1+35,x2-40,y2-60);
     buton(x2-40,y1+35,15,20,0,chr(24));
     buton(x2-40,y2-80,15,20,0,chr(25));
     settextstyle(0,0,1);
     buton(x1+30,y2-45,100,25,0,b1);
     buton(x2-130,y2-45,100,25,0,b2);
     setfillstyle(1,7);
     bar(x2-39,y1+56,x2-26,y2-81);
     setcolor(0);
     repeat
          if extsel<>antextsel then for i:=1 to 15 do if i<=cant then begin
             if index[extsel+i]=true then setfillstyle(1,3) else setfillstyle(1,15);
             bar(x1+28,y1+27+13*i,x2-42,y1+26+13*(i+1));
             outtextxy(x1+30,y1+30+13*i,item[extsel+i]);
          end;
          if (antsel<>sel) or (antextsel<>extsel) then begin
             if cant>15 then begin
                setfillstyle(1,7);
                bar(x2-39,y1+56,x2-26,y2-81);
                buton(x2-40,y1+55+trunc((extsel+sel)*(165-trunc(165*15/cant))/cant),
                       15,trunc(165*15/cant),0,' ');
             end;
             setlinestyle(1,0,0);
             if index[extsel+antsel]=true then setcolor(3) else setcolor(15);
             rectangle(x1+28,y1+27+13*antsel,x2-42,y1+26+13*(antsel+1));
             setcolor(0);
             rectangle(x1+28,y1+27+13*sel,x2-42,y1+26+13*(sel+1));
             antsel:=sel;
             antextsel:=extsel;
          end;
          buton(x1+30,y2-45,100,25,3,b1);
          buton(x2-130,y2-45,100,25,3,b2);
          case selec of
               1:buton(x1+30,y2-45,100,25,1,b1);
               2:buton(x2-130,y2-45,100,25,1,b2);
		end;
		{ polling: tecla o click en boton / item / scrollbar (reconstruccion 1.2) }
		key:=#1; { centinela }
		repeat
               if keypressed then begin
                    key:=readkey;
                    break;
               end;
               if mouseHit(x1+30,y2-45,x1+130,y2-20) then begin
                    selec:=1; key:=#13; break;
               end;
               if mouseHit(x2-130,y2-45,x2-30,y2-20) then begin
                    selec:=2; key:=#13; break;
               end;
               if hasMouse and MouseDown(1) then begin
                    scrollDone:=false;
                    { flecha arriba del scrollbar }
                    if Mouseln(x2-41,y1+34,x2-24,y1+56) then begin
                         if sel>1 then dec(sel)
                              else if extsel>0 then dec(extsel);
                         scrollDone:=true;
                    end
                    { flecha abajo del scrollbar }
                    else if Mouseln(x2-41,y2-81,x2-24,y2-59) then begin
                         if (sel<15) and (sel<cant) then inc(sel)
                              else if extsel+sel<cant then inc(extsel);
                         scrollDone:=true;
                    end
                    { click directo en el track: salta proporcionalmente }
                    else if (cant>15) and Mouseln(x2-40,y1+55,x2-25,y2-80) then begin
                         trackH:=(y2-80)-(y1+55);
                         if trackH<1 then trackH:=1;
                         target:=round((MouseY-(y1+55))*cant/trackH);
                         if target<1 then target:=1;
                         if target>cant then target:=cant;
                         extsel:=target-1;
                         if extsel<0 then extsel:=0;
                         if extsel>cant-15 then extsel:=cant-15;
                         sel:=target-extsel;
                         if sel<1 then sel:=1;
                         if sel>15 then sel:=15;
                         scrollDone:=true;
                    end;
                    if scrollDone then begin
                         while MouseDown(1) do ;
                    end else begin
                         { click directo sobre un item visible de la lista }
                         i:=1;
                         while (i<=15) and (extsel+i<=cant) do begin
                              if Mouseln(x1+28,y1+27+13*i,x2-42,y1+40+13*i) then begin
                                   sel:=i;
                                   selec:=0;
                                   if maxindex=1 then key:=#13 else key:=#32;
                                   while MouseDown(1) do ;
                                   break;
                              end;
                              inc(i);
                         end;
                         if (key=#13) or (key=#32) then break;
                         while MouseDown(1) do ;
                    end;
               end;
          until false;
          setcolor(0);
          if (selec=0) and (key=#13) and (maxindex=1) then index[sel+extsel]:=true;
          case key of
          	#13,#32:case selec of
                    1:begin
                         if maxindex=1 then index[sel+extsel]:=true;
                         buton(x1+30,y2-45,100,25,2,b1);
                    end;
                    2:begin
				       buton(x2-130,y2-45,100,25,2,b2);
                           index[0]:=true;
                           for i:=1 to cant do index[i]:=false;
                    end;
               end;
               #9:if selec=2 then selec:=0 else inc(selec);
               #27:begin
                    index[0]:=true;
                    for i:=1 to cant do index[i]:=false;
               end;
               #0:begin key:=readkey;
                    if key=#15 then if selec=0 then selec:=2 else dec(selec);
               end;
          end;
          if selec=0 then case key of
             #32:if (index[extsel+sel]=true) or (sumselec<maxindex) then begin
                  if index[extsel+sel]=true then begin
                     dec(sumselec);
                     index[extsel+sel]:=false;
                     setfillstyle(1,15); end
                  else if sumselec<maxindex then begin
                       inc(sumselec);
                       index[extsel+sel]:=true;
                       setfillstyle(1,3);
                  end;
                  bar(x1+28,y1+27+13*sel,x2-42,y1+26+13*(sel+1));
                  outtextxy(x1+30,y1+30+13*sel,item[extsel+sel]);
                  setlinestyle(1,0,0);
                  rectangle(x1+28,y1+27+13*sel,x2-42,y1+26+13*(sel+1)); end
             else beep;
             #72:if sel>1 then dec(sel) else if extsel>0 then dec(extsel);
             #80:if (sel<15) and (sel<cant) then inc(sel) else if extsel+sel<cant then inc(extsel);
             #71:begin sel:=1; extsel:=0; end;
             #79:if cant>15 then begin extsel:=cant-15; sel:=15; end else sel:=cant;
             #73:if extsel>0 then if extsel>=15 then dec(extsel,15)
                    else begin sel:=1; extsel:=0; end else sel:=1;
             #81:if cant>15 then if extsel+sel+30<=cant then inc(extsel,15)
                    else begin sel:=15; extsel:=cant-15; end else sel:=cant;
          end;
     until (((key=#13) or (key=#32)) and (selec<>0)) or (key=#27)
           or ((key=#13) and (sumselec>0)) or ((key=#13) and (maxindex=1));
     if (sumselec=0) and (maxindex>1) then index[0]:=true;
     if selec<>0 then delay(200);
     putimg(x1,y1,x2,y2);
end;

procedure clsout;
var 	x,y:word;

begin
     y:=0;
     repeat
          for x:=0 to round(getmaxx/40)-1 do begin
		    line(20*x+y,0,20*x+y,getmaxy);
		    line(getmaxx-20*x-y,0,getmaxx-20*x-y,getmaxy);
     	end;
     	inc(y);
     until y=20;
     cleardevice;
end;

procedure getimg; {procedimiento que define memoria y captura imagen}

begin
     getmem(p,imagesize(x1,y1,x2,y2));
     getimage(x1,y1,x2,y2,p^);
end;

procedure putimg; {procedimiento que devuelve la imagen y libera memoria}

begin
	putimage(x1,y1,p^,normalput);
     freemem(p,imagesize(x1,y1,x2,y2));
end;

end.