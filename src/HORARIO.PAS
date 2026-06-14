{********************************************************************}
{ Generador de Horarios versi¢n Beta96.                              }
{ Versi¢n en Modo Gr fico.                                           }
{ Elaborado por: Oscar Zamora Plasencia                              }
{                                                                    }
{                            Copyright (C) ZmS Software, 1995 - 1996 }
{********************************************************************}

{$M 65520,0,655360}
program Generador_de_Horarios;

uses	crt,graph,uhora,uhora2;
const mn:array[1..14] of string=
     ('Nombre del Archivo',
     'Adicionar Curso',
     'Modificar/Verificar Curso',
     'Borrar Curso',
     'Informaci¢n del Archivo',
	'Generar Horarios Posibles',
     'Ver/Imprimir Horarios',
     'Adicionar Curso a la Base',
     'Modificar Curso de la Base',
     'Borrar Curso de la Base',
     'Cursos en la Base de Datos',
	'Ayuda',
	'Acerca de...',
	'Salir');

type mathora=array[1..24] of integer;
     apuntacur=^regcur;
     apuntahor=^reghora;
     regcur=record
          codigo:string[5];
          nombre:string[12];
          ht:integer;
          flag:char;
          enlace:apuntacur;
     end;
     reghora=record
          codigo:string[5];
          seccion:string[4];
          profesor:string[8];
          flag:char;
          hora:mathora;
          enlace:apuntahor;
     end;
     regcuadre=record
          seccion:array[1..16] of string[5];
     end;

var  archhor:string;
     txt,out:array[1..10] of string;
     max:array[1..10] of byte;
     cursos,inicur,lugcur:apuntacur;
     totregcur:word;
     horarios,inihor,lughor:apuntahor;
     totreghor:word;
     filecur:file of regcur;
     filehor:file of reghora;
     cuadres:file of regcuadre;

     rcur:regcur;
     rhor:reghora;
     rtemp:regcuadre;

     posibles:boolean;
     totcuadres:longint;
     tomaitem:tpindex;
     selopt:tpitem;
     vaciohor:array[1..15,1..6] of boolean;
     posit:integer;

procedure infonom; forward;

procedure genera; forward;

procedure acthorario;
var busc:apuntahor;
    i:integer;

begin
     if archhor<>'' then begin
        rewrite(filehor);
        i:=0;
        busc:=inihor;
        while busc<>nil do begin
           inc(i);
           seek(filehor,i);
           write(filehor,busc^);
           busc:=busc^.enlace;
	   end;
     end;
end;

procedure infocur(c:string; var n:string; var h:integer);
var busc:apuntacur;

begin
     busc:=inicur;
     while busc<>nil do begin
        if busc^.codigo=c then begin
	      n:=busc^.nombre;
           h:=busc^.ht;
           exit;
        end;
        busc:=busc^.enlace;
	end;
     h:=0;
end;

procedure infohor(c,s:string; var n,p:string; var numhora:integer; var horapos:mathora);
var cod,nom:string;
    hor:integer;
    busc:apuntahor;

begin
     busc:=inihor;
     while busc<>nil do begin
        if (busc^.codigo=c) and (busc^.seccion=s) then begin
           infocur(c,nom,hor);
	      n:=nom;
           p:=busc^.profesor;
           numhora:=hor;
           horapos:=busc^.hora;
           exit;
        end;
        busc:=busc^.enlace;
	end;
end;

procedure refresh;
var i:byte;

begin
     ventcls(0,0,getmaxx,getmaxy,3,9,'Generador de Horarios');
     ventana(310,28,620,100,15,1,'Archivo Abierto');
     ventana(310,110,620,471,15,2,'Informaci¢n');
     ventana(20,28,290,471,15,3,'Men£ General');
     for i:=1 to 14 do buton(30,30+29*i,250,25,0,mn[i]);
     infonom;
end;

procedure tabla(op:shortint; numcur:integer; cod,sec:array of string);
var key:char;
    antx,anty,x,y,tothora,cont:integer;
    nom,prof,s:string;
    hpos:mathora;
    table:array[1..15,1..6] of boolean;
    i,j:integer;

begin
     for i:=1 to 15 do for j:=1 to 6 do table[i,j]:=false;
     case op of
          0:ventana(20,25,620,474,15,2,'Definici¢n de Horas');
          1:ventcls(20,25,620,474,15,2,'Horarios Posibles');
          2:ventana(20,25,620,474,15,2,'Horas que no se Desean');
     end;
     setcolor(0);
     for i:=1 to 7 do line(80*i,76,80*i,436);
     for i:=1 to 16 do line(80,52+24*i,560,52+24*i);
     for i:=1 to 15 do outtextxy(35,60+24*i,strval(i+6)+':00');
     setcolor(4);
     outtextxy(100,62,'LUNES     MARTES  MIERCOLES   JUEVES   VIERNES   SABADO');
     if op=1 then begin
        settextstyle(2,0,4);
        outtextxy(35,442,'Teclas:');
        outtextxy(85,444,'<Pg Up>   Anterior   <Home> Primero  <Esc> Salir  <F5> Ir a  <Enter> Imprimir ');
        outtextxy(85,456,'<Pg Down> Siguiente  <End>  Ultimo   <Ctrl>+<Enter> Imprimir lista de secciones');
        setcolor(0);
        settextstyle(2,0,4);
        setfillstyle(1,7);
        for i:=1 to numcur do begin
            infohor(cod[i-1],sec[i-1],nom,prof,tothora,hpos);
            s:=sec[i-1];
            j:=0;
            repeat
                bar(80*hpos[j+2]+2,54+24*hpos[j+1],80*(hpos[j+2]+1)-2,50+24*(hpos[j+1]+1));
                outtextxy(80*hpos[j+2]+2,54+24*hpos[j+1],nom);
                outtextxy(80*hpos[j+2]+2,64+24*hpos[j+1],prof+space(8-length(prof))+space(5-length(s))+s);
                inc(j,2);
            until j=tothora*2;
        end;
        setcolor(8);
        for i:=1 to 15 do for j:=1 to 6 do if vaciohor[i,j]=true then
            outtextxy(80*j+2,54+24*i,' NO DESEADO');
        exit;
     end;
     settextstyle(2,0,4);
     outtextxy(35,442,'Teclas:');
     outtextxy(85,442,'<Esc> Salir sin grabar                 <Enter> Salir grabando posici¢n de horas');
     outtextxy(85,455,'<Tab>, Flechas: desplazamiento          Barra espaciadora: marca/desmarca hora');
     setcolor(0);
     setfillstyle(1,7);
     antx:=1; anty:=1;
     x:=1; y:=1;
     if op=0 then infocur(cod[0],nom,tothora) else tothora:=90;
     for i:=1 to 15 do for j:=1 to 6 do table[i,j]:=false;
     j:=0;
     cont:=0;
     if (horarios^.hora[1]>0) and (op=0) then repeat
          table[horarios^.hora[j+1],horarios^.hora[j+2]]:=true;
          inc(cont);
          bar(80*horarios^.hora[j+2]+2,54+24*horarios^.hora[j+1],80*(horarios^.hora[j+2]+1)-2,
                   50+24*(horarios^.hora[j+1]+1));
          outtextxy(80*horarios^.hora[j+2]+2,54+24*horarios^.hora[j+1],nom);
          outtextxy(80*horarios^.hora[j+2]+2,64+24*horarios^.hora[j+1],horarios^.profesor+
                   space(8-length(horarios^.profesor))+space(5-length(sec[0]))+sec[0]);
          inc(j,2);
     until j=tothora*2;
     repeat
          settextstyle(2,0,4);
          if table[anty,antx]=false then setfillstyle(1,15) else setfillstyle(1,7);
          bar(80*antx+2,54+24*anty,80*(antx+1)-2,50+24*(anty+1));
          if table[anty,antx]=true then
             if op=2 then outtextxy(80*antx+2,54+24*anty,' NO DESEADO') else begin
                outtextxy(80*antx+2,54+24*anty,nom);
                outtextxy(80*antx+2,64+24*anty,horarios^.profesor+space(8-
                    length(horarios^.profesor))+space(5-length(sec[0]))+sec[0]);
             end;
          setfillstyle(1,3);
          bar(80*x+2,54+24*y,80*(x+1)-2,50+24*(y+1));
          if (table[y,x]=true) then
             if op=2 then outtextxy(80*x+2,54+24*y,' NO DESEADO') else begin
                outtextxy(80*x+2,54+24*y,nom);
                outtextxy(80*x+2,64+24*y,horarios^.profesor+space(8-length(horarios^.profesor))+
                      space(5-length(sec[0]))+sec[0]);
             end;
          key:=readkey;
          antx:=x; anty:=y;
          case key of
          	#9:if x=6 then begin x:=1; if y=15 then y:=1 else inc(y) end else inc(x);
               #13:begin
                    if (cont<>tothora) and (op=0) then begin
	                  txt[1]:='No se han llegado a';
                       txt[2]:='definir las '+strval(tothora)+' horas.';
                       msgbox('Tabla Incompleta',0,2,txt); end
                    else begin
	                  txt[1]:='¨Desea grabar las horas';
                       txt[2]:='definidas en la tabla?';
                       if msgbox('Grabar Horas Definidas',1,2,txt)=true then begin
                          if op=0 then begin
                             cont:=0;
                             for i:=1 to 15 do for j:=1 to 6 do if table[i,j]=true then begin
                                 horarios^.hora[cont+1]:=i;
                                 horarios^.hora[cont+2]:=j;
                                 inc(cont,2);
                             end;
                             inc(totreghor); end
                          else for i:=1 to 15 do for j:=1 to 6 do vaciohor[i,j]:=table[i,j];
                       refresh;
                       exit;
                       end;
                    end;
               end;
               #27:begin
	               txt[1]:='¨Desea Salir sin grabar las';
                    txt[2]:='horas definidas en la tabla?';
                    if msgbox('Salir sin Grabar',1,2,txt)=true then begin
                       if op=2 then for i:=1 to 15 do for j:=1 to 6 do vaciohor[i,j]:=false;
                       refresh;
                       exit;
                    end;
               end;
			#32:begin
                    if table[y,x]=true then begin
                       table[y,x]:=false;
                       dec(cont); end
                    else if cont<tothora then begin
                         table[y,x]:=true;
                         inc(cont); end
                         else beep;
               end;
			#0:begin key:=readkey;
               	case key of
					#15:if x=1 then begin x:=6; if y=1 then y:=15 else dec(y) end else dec(x);
                         #72:if y=1 then y:=15 else dec(y);
                         #75:if x=1 then x:=6 else dec(x);
                         #77:if x=6 then x:=1 else inc(x);
                         #80:if y=15 then y:=1 else inc(y);
                    end;
               end;
     	end;
	until false;
end;

procedure impcuadres;
var j,x,y,z,tcur:integer;
    anti,i:longint;
    arrcod,arrsec:array[1..15] of string;
    temp:string;
    key:char;
    lst:text;
    tempprint:array[1..46,1..80] of string[1];
    nom,prof:string;
    tothora:integer;
    hpos:mathora;
    error,msg:boolean;

begin
     assign(lst, 'LPT1');
     rewrite(lst);
     if posibles=false then begin
        genera;
        if posibles=false then exit;
     end;
     reset(cuadres);
     tcur:=0;
     if eof(cuadres) then begin
	   txt[1]:='No existen horarios posibles.';
        txt[2]:='Sugerencia: incremente el n£mero';
        txt[3]:='de secciones en algun(os) curso(s).';
        msgbox('Sin horarios Posibles',0,3,txt);
        exit;
     end;
     seek(cuadres,0);
     read(cuadres,rtemp);
     repeat
          inc(tcur);
          arrcod[tcur]:=rtemp.seccion[tcur];
     until rtemp.seccion[tcur+1]='@';
     ventana(20,25,620,474,15,2,'Horarios Posibles');
     i:=1;
     anti:=0;
     repeat
          if anti<>i then begin
             anti:=i;
             seek(cuadres,i);
             read(cuadres,rtemp);
             for j:=1 to tcur do arrsec[j]:=rtemp.seccion[j];
             tabla(1,tcur,arrcod,arrsec);
             setcolor(0);
             outtextxy(483,435,space(13-length(strval(i)+'/'+strval(totcuadres)))+
                  strval(i)+'/'+strval(totcuadres));
          end;
          key:=readkey;
          case key of
               #10,#13:begin
                   msg:=true;
                   repeat
                        {$I-}
                        writeln(lst);
                        {$I+}
                        if IOResult<>0 then begin
                           error:=true;
                           beep;
	                      txt[1]:='No se puede imprimir.';
                           txt[2]:='Es probable que su impresora';
                           txt[3]:='no se encuntre lista (ON LINE).';
                           txt[4]:='¨Reintentar Impresi¢n?';
                           msg:=msgbox('Imprimir',1,4,txt); end
                        else error:=false;
                   until (error=false) or (msg=false);
                   if msg=true then begin
                     if key=#10 then begin
                       writeln(lst,'Listado de Secciones: (Horario ',i,'/',totcuadres,')');
                       writeln(lst);
                       for x:=1 to tcur do begin
                           infohor(arrcod[x],arrsec[x],nom,prof,tothora,hpos);
                           writeln(lst,nom+space(14-length(nom)),arrsec[x]+space(6-length(arrsec[x])),prof);
                       end; end
                     else begin
                       writeln(lst,'     Lunes        Martes     Mi‚rcoles     Jueves       Viernes      S bado');
                       for x:=1 to 80 do for y:=1 to 46 do tempprint[y,x]:=' ';
                       for x:=2 to 79 do begin
                         tempprint[1,x]:='Í';
                         tempprint[46,x]:='Í';
                         if (x-2) mod 13=0 then begin
                            tempprint[1,x]:='Ñ';
                            tempprint[46,x]:='Ï';
                         end;
                         for y:=4 to 43 do if (y-1) mod 3=0 then tempprint[y,x]:='Ä';
                       end;
                       for y:=2 to 45 do begin
                         tempprint[y,2]:='º';
                         tempprint[y,80]:='º';
                         if (y-1) mod 3=0 then begin
                            tempprint[y,2]:='Ç';
                            tempprint[y,80]:='¶';
                         end;
                         for x:=15 to 77 do if (x-2) mod 13=0 then
                             if (y-1) mod 3=0 then tempprint[y,x]:='Å'
                                 else tempprint[y,x]:='³';
                       end;
                       tempprint[1,2]:='É'; tempprint[1,80]:='»';
                       tempprint[46,2]:='È'; tempprint[46,80]:='¼';
                       for y:=2 to 8 do if (y+1) mod 3=0 then tempprint[y,1]:='0';
                       for y:=11 to 38 do if (y+1) mod 3=0 then tempprint[y,1]:='1';
                       tempprint[41,1]:='2'; tempprint[44,1]:='2';
                       x:=6;
                       for y:=3 to 45 do if y mod 3=0 then begin
                           inc(x);
                           if x=10 then x:=0;
                           tempprint[y,1]:=strval(x);
                       end;
                       for x:=1 to tcur do begin
                           infohor(arrcod[x],arrsec[x],nom,prof,tothora,hpos);
                           y:=0;
                           repeat
                                for z:=1 to length(nom) do tempprint[hpos[y+1]*3-1,hpos[y+2]*13-11+z]:=nom[z];
                                temp:=prof+space(8-length(prof))+space(4-length(arrsec[x]))+arrsec[x];
                                for z:=1 to length(temp) do tempprint[hpos[y+1]*3,hpos[y+2]*13-11+z]:=temp[z];
                                inc(y,2);
                           until y=tothora*2;
                       end;
                       for y:=1 to 46 do begin
                           for x:=1 to 79 do write(lst,tempprint[y,x]);
                           writeln(lst,tempprint[y,80]);
                       end;
                       writeln(lst,'  Horario ',i,'/',totcuadres);
                     end;
                     writeln(lst);
                   end;
               end;
               #0:begin; key:=readkey;
                 case key of
                    #63:begin
                           txt[1]:='Horario N£mero:'; max[1]:=6; out[1]:='';
                           gettext('Ir al N£mero de Horario',1,max,txt,out);
                           if alltrim(out[1])<>#27 then
                              if (numval(out[1])>0) and (numval(out[1])<=totcuadres)
                                 then i:=trunc(numval(out[1])) else begin
                                      beep;
	                                 txt[1]:='El n£mero ingresado no es v lido.';
                                      msgbox('Error en el Ingreso',0,1,txt);
                              end;
                    end;
                    #73:if i>1 then dec(i) else beep;
                    #81:if not eof(cuadres) then inc(i) else beep;
                    #71:if i>1 then i:=1 else beep;
                    #79:if i<totcuadres then i:=totcuadres else beep;
                 end;
               end;
          end;
     until key=#27;
     close(lst);
     refresh;
end;

procedure genera;
type schd=record
          sec:string[4];
          hor:mathora;
     end;

var curtemp:array[1..15,1..25] of schd;
    top,max,tothora:array[1..15] of integer;
    cod:array[1..15] of string[5];
    totcur:integer;
    table:array[1..15,1..6] of boolean;
    cruce,vacio:boolean;
    n:string;
    h,i,j,l,totsec:integer;
    k,grantotal:longint;
    ndes:shortint;
    busc:apuntahor;

begin
     i:=0;
     k:=0;
     vacio:=true;
     grantotal:=0;
     totcur:=0;
     cod[1]:='';
     if totreghor=0 then begin
	   txt[1]:='El archivo de horarios abierto';
        txt[2]:='no tiene alguna secci¢n almacenada.';
        txt[3]:='Adicione para generar horarios.';
        msgbox('Archivo de Horarios Vac¡o',0,3,txt);
        exit;
     end;
     i:=0;
     busc:=inihor;

     while busc<>nil do begin
         infocur(busc^.codigo,n,h);
         if h<1 then begin
            txt[1]:='El curso '+busc^.codigo+' no se encuentra';
            txt[2]:='en la base de datos. Ingr‚selo';
            txt[3]:='a la base para generar horarios.';
            msgbox('C¢digo Inexistente',0,3,txt);
            exit;
         end;
         inc(i);
         selopt[i]:=n+space(14-length(n))+busc^.seccion+
             space(6-length(busc^.seccion))+busc^.profesor;
         busc:=busc^.enlace;
     end;

     selectitem('Selecci¢n de Cursos',totreghor,totreghor,selopt,tomaitem);
     if tomaitem[0]=true then exit;
     for i:=1 to 15 do for j:=1 to 6 do vaciohor[i,j]:=false;
	txt[1]:='¨Des‚a marcar horas que no';
     txt[2]:='quiere usar en los horarios?';
     if msgbox('Marcar Horas',1,2,txt)=true then tabla(2,1,n,n);
     rewrite(cuadres);

     i:=0;
     busc:=inihor;
     while busc<>nil do begin
        inc(i);
        if tomaitem[i]=true then begin
           j:=0;
           repeat
              inc(j);
              if busc^.codigo=cod[j] then begin
                 inc(max[j]);
                 with curtemp[j,max[j]] do begin
                      sec:=busc^.seccion;
                      hor:=busc^.hora;
                 end;
              end;
           until (j=totcur) or (busc^.codigo=cod[j]) or (totcur=0);
        end;
        if (busc^.codigo<>cod[j]) or (totcur=0) then begin
           inc(totcur);
           max[totcur]:=1;
           cod[totcur]:=busc^.codigo;
           infocur(busc^.codigo,n,h);
           tothora[totcur]:=h;
           with curtemp[totcur,1] do begin
                 sec:=busc^.seccion;
                 hor:=busc^.hora;
           end;
         end;
         busc:=busc^.enlace;
     end;

     ventcls(310,110,620,471,15,2,'Informaci¢n');
     setcolor(4);
     settextstyle(2,0,4);
     outtextxy(330,140,'Generando Horarios . . .');
     for i:=1 to totcur-1 do top[i]:=1;
     top[totcur]:=0;
     k:=0;
     while top[1]<max[1]+1 do begin
        inc(grantotal);
        inc(top[totcur]);
        for i:=totcur downto 1 do
            if (i>1) and (top[i]=max[i]+1) then begin
               top[i]:=1;
               inc(top[i-1]);
            end;
        if top[1]<=max[1] then begin
           cruce:=false;
           for i:=1 to 15 do for j:=1 to 6 do table[i,j]:=vaciohor[i,j];
           for i:=1 to totcur do
               for j:=1 to tothora[i] do
                   with curtemp[i,top[i]] do
                        if table[hor[j*2-1],hor[j*2]]=false then table[hor[j*2-1],hor[j*2]]:=true
                           else cruce:=true;
           if cruce=false then begin
              if k=0 then begin
                 for i:=1 to totcur do rtemp.seccion[i]:=cod[i];
                 rtemp.seccion[totcur+1]:='@';
                 seek(cuadres,k);
                 write(cuadres,rtemp);
              end;
              inc(k);
              for i:=1 to totcur do rtemp.seccion[i]:=curtemp[i,top[i]].sec;
              seek(cuadres,k);
              write(cuadres,rtemp);
           end;
        end;
     end;
     dec(grantotal);
     ventcls(310,110,620,471,15,2,'Informaci¢n de Horarios Generados');
     setcolor(4);
     settextstyle(2,0,4);
     outtextxy(330,140,'Horarios Posibles: '+strval(k));
     outtextxy(330,160,'Horarios con Cruce: '+strval(grantotal-k));
     outtextxy(330,170,'Total de Combinaciones: '+strval(grantotal));
     outtextxy(330,190,'Total de Cursos: '+strval(totcur));
     outtextxy(330,210,'Total de Secciones por Cursos:');
     totsec:=0;
     for i:=1 to totcur do begin
         infocur(cod[i],n,h);
         outtextxy(330,220+12*i,n);
         if max[i]=1 then outtextxy(430,220+12*i,strval(max[i])+' secci¢n') else
            outtextxy(430,220+12*i,strval(max[i])+' secciones');
         inc(totsec,max[i]);
     end;
     outtextxy(330,220+12*(i+2),'Total de Secciones: '+strval(totsec));
     l:=i+4;
     ndes:=0;
     for i:=1 to 15 do for j:=1 to 6 do if vaciohor[i,j]=true then inc(ndes);
     outtextxy(330,220+12*l,'Total de Horas no Deseadas: '+strval(ndes));
	txt[1]:='Horarios Posibles: '+strval(k);
     txt[2]:='Horarios con Cruce: '+strval(grantotal-k);
     txt[3]:='Total de Combinaciones: '+strval(grantotal);
     msgbox('Informaci¢n de Posibilidades',0,3,txt);
     posibles:=true;
     totcuadres:=k;
end;

procedure abrehor;
var i:integer;
    busc,dato:apuntahor;

begin
     out[1]:='';
     repeat
          txt[1]:='Archivo:'; max[1]:=37;
          gettext('Nombre del Archivo de Horario',1,max,txt,out);
          if out[1]=#27 then exit;
          if (out[1]='') or (pos(' ',out[1])>0) or (trim(out[1])='CURSOS.DAT') then begin
	        txt[1]:='Nombre del archivo no especificado ';
             txt[2]:='o mal especificado.';
             msgbox('Error en el Ingreso',0,2,txt);
          end;
     until (out[1]<>'') and (pos(' ',out[1])=0) and (trim(out[1])<>'CURSOS.DAT');
     out[1]:=trim(out[1]);
     if pos('.',out[1])=0 then out[1]:=out[1]+'.HOR';
     acthorario;
	{$I-}
     assign(filehor,out[1]);
     reset(filehor);
     {$I+}
     if IOResult<>0 then begin
	   txt[1]:='Archivo no existe:';
        txt[2]:=out[1];
        txt[3]:='¨Des‚a crearlo?';
        if msgbox('Archivo Nuevo',1,3,txt)=true then begin
           rewrite(filehor);
           totreghor:=0;
           archhor:=out[1]; end
        else exit; end
     else begin
        totreghor:=0;
        archhor:=out[1];
        i:=0;

        new(inihor);
        new(dato);
        busc:=inihor;

        while not eof(filehor) do begin
           inc(i);
           seek(filehor,i);
           read(filehor,dato^);
           if dato^.flag='@' then begin
              inc(totreghor);
              busc:=inihor;
              while busc<>nil do begin
                    if lughor^.codigo<busc^.codigo then begin
                          horarios^:=busc^;
                          busc^:=lughor^;
                          new(busc^.enlace);
                          busc^:=horarios^
                    end;
                    busc:=busc^.enlace;
	         end;
           end;
        end;
	   txt[1]:='Reabriendo Archivo:';
        txt[2]:=archhor;
        msgbox('Archivo Existente',0,2,txt);
     end;
     ventcls(310,110,620,471,15,2,'Informaci¢n');
end;

procedure abrecur;
var i:integer;

begin
     totregcur:=0;
	{$I-}
     assign(filecur,'Cursos.Dat');
     reset(filecur);
     {$I+}
     if IOResult<>0 then begin
	   txt[1]:='La Base de Datos de Cursos no existe.';
        txt[2]:='Se crear  con el nombre CURSOS.DAT.';
        msgbox('Creaci¢n de Base de Datos',0,2,txt);
        assign(filecur,'Cursos.Dat');
        rewrite(filecur); end
     else begin
        i:=0;
        new(inicur);
        lugcur:=inicur;
        while not eof(filecur) do begin
           inc(i);
           seek(filecur,i);
           read(filecur,rcur);
           if rcur.flag='@' then begin
              inc(totregcur);
              cursos[totregcur]:=rcur;
           end;
        end;
     end;
end;

procedure editcur(op:integer);
var i:integer;
    sw:boolean;
    cod:string;

begin
     if (op>0) and (op<3) then begin
        if totregcur=0 then begin
	      txt[1]:='La Base de Datos, archivo';
           txt[2]:='CURSOS.DAT, se encuentra vac¡a.';
           msgbox('Archivo de Cursos Vac¡o',0,2,txt);
           exit;
        end;
        for i:=1 to 500 do tomaitem[i]:=false;
        for i:=1 to totregcur do with cursos[i] do selopt[i]:=codigo+space(6-length(codigo))
                 +nombre+space(14-length(nombre))+strval(ht)+' horas';
        selectitem('Selecci¢n del Curso',i,1,selopt,tomaitem);
        if tomaitem[0]=true then exit;
        i:=1;
        while tomaitem[i]=false do inc(i);
        case op of
             1:begin
                  sw:=false;
                  out[1]:=cursos[i].nombre;
                  out[2]:=strval(cursos[i].ht);
                  repeat
                     txt[1]:='Nombre del Curso:'; max[1]:=12;
                     txt[2]:='N£mero de Horas: '; max[2]:=2;
                     gettext('Modificaci¢n del Curso: '+cursos[i].codigo,2,max,txt,out);
                     if out[1]=#27 then exit;
                     out[1]:=trim(out[1]);
                     out[2]:=trim(out[2]);
                     if (out[1]='') or (numval(out[2])>12) or (numval(out[2])<2) then begin
	                   txt[1]:='Alg£n campo est  vac¡o o';
                        txt[2]:='contiene informaci¢n err¢nea';
                        txt[3]:='';
                        txt[4]:='El n£mero de horas debe ser:';
                        txt[5]:='2 ó Horas ó 12';
                        msgbox('Error en el Ingreso',0,5,txt); end
                     else begin
                        txt[1]:='Los datos que contiene el curso son:';
                        txt[2]:='C¢digo: '+cursos[i].codigo;
                        txt[3]:='Nombre: '+out[1];
                        txt[4]:='Horas: '+out[2];
                        sw:=msgbox('Verificaci¢n de Datos',1,4,txt);
                     end;
                  until (out[1]<>'') and (numval(out[2])<13) and (numval(out[2])>1) and (sw=true);
                  with cursos[i] do begin
                       nombre:=out[1];
                       ht:=trunc(numval(out[2]));
                  end;
                  SortCursos(1,totregcur);
             end;
             2:begin
	             txt[1]:='El curso con c¢digo '+cursos[i].codigo;
                  txt[2]:='con nombre '+cursos[i].nombre;
                  txt[3]:='va a ser borrado.';
                  if msgbox('Borrar Curso',1,3,txt)=false then exit;
                  cursos[i]:=cursos[totregcur];
                  dec(totregcur);
                  if totregcur>0 then SortCursos(1,totregcur);
             end;
        end; end
     else begin
        if op=0 then begin
           out[1]:='';
           while out[1]='' do begin
                 txt[1]:='C¢digo del Curso:'; max[1]:=5;
                 gettext('Nuevo Curso para la Base de Datos',1,max,txt,out);
                 out[1]:=trim(out[1]);
                 if out[1]='' then begin
	               txt[1]:='No ha ingresado el C¢digo';
                    msgbox('C¢digo No Ingresado',0,1,txt);
                 end;
           end;
           if out[1]=#27 then exit;
           for i:=1 to totregcur do if cursos[i].codigo=out[1] then begin
	          txt[1]:='El curso c¢digo '+alltrim(out[1])+' ya existe.';
               txt[2]:='Solo puede modificarlo o borrarlo.';
               msgbox('C¢digo Ya Existe',0,2,txt);
               exit;
           end;
        end;
        cod:=out[1];
        out[1]:='';
        out[2]:='';
        sw:=false;
        repeat
             txt[1]:='Nombre del Curso:'; max[1]:=12;
             txt[2]:='N£mero de Horas: '; max[2]:=2;
             gettext('Creaci¢n de Curso: '+cod,2,max,txt,out);
             if out[1]=#27 then exit;
             out[1]:=trim(out[1]);
             out[2]:=trim(out[2]);
             if (out[1]='') or (numval(out[2])>12) or (numval(out[2])<2) then begin
	           txt[1]:='Alg£n campo est  vac¡o o';
                txt[2]:='contiene informaci¢n err¢nea';
                txt[3]:='';
                txt[4]:='El n£mero de horas debe ser:';
                txt[5]:='2 ó Horas ó 12';
                msgbox('Error en el Ingreso',0,5,txt); end
             else begin
                  txt[1]:='Los datos que contiene el curso son:';
                  txt[2]:='C¢digo: '+cod;
                  txt[3]:='Nombre: '+out[1];
                  txt[4]:='Horas: '+out[2];
                  sw:=msgbox('Datos en la Base',1,4,txt);
             end;
        until (out[1]<>'') and (numval(out[2])<13) and (numval(out[2])>1) and (sw=true);
        inc(totregcur);
        with cursos[totregcur] do begin
             codigo:=cod;
             nombre:=out[1];
             ht:=trunc(numval(out[2]));
             flag:='@';
        end;
        SortCursos(1,totregcur);
     end;
end;

procedure edithor(op:integer);
var nom,cod,prof,sec:string;
    i,j,hor:integer;
    sw:boolean;

begin
     if op<>0 then begin
        if totreghor=0 then begin
	      txt[1]:='El archivo en uso no tiene';
           txt[2]:='secciones almacenadas.';
           msgbox('Archivo de Horario Vac¡o',0,2,txt);
           exit;
        end;
        for i:=1 to 375 do tomaitem[i]:=false;
        for i:=1 to totreghor do begin
            infocur(horarios[i].codigo,nom,hor);
            if hor<1 then selopt[i]:=horarios[i].codigo+' no existe. Secci¢n: '+horarios[i].seccion
                    else selopt[i]:=nom+space(14-length(nom))+horarios[i].seccion+
                    space(6-length(horarios[i].seccion))+horarios[i].profesor;
        end;
        selectitem('Selecci¢n del Curso y Secci¢n',i,1,selopt,tomaitem);
        if tomaitem[0]=true then exit;
        i:=1;
        while tomaitem[i]=false do inc(i);
        infocur(horarios[i].codigo,nom,hor);
        case op of
             1:begin
                  if hor<1 then begin
	                txt[1]:='El curso '+horarios[i].codigo+' no puede ser modificado';
                     txt[2]:='por no existir en la base de datos.';
                     txt[3]:='Adici¢nelo a la base de datos para';
                     txt[4]:='que la secci¢n pueda ser modificada.';
                     msgbox('Curso no Existe',0,4,txt);
                     exit;
                  end;
                  out[1]:=horarios[i].profesor;
                  repeat
                      txt[1]:='Profesor: '; max[1]:=8;
                      gettext('Curso: '+nom+', Secci¢n: '+horarios[i].seccion,1,max,txt,out);
                      if out[1]=#27 then exit;
                      prof:=trim(out[1]);
                      if prof='' then begin
	                    txt[1]:='No ha ingresado el nombre';
                         txt[2]:='del profesor.';
                         msgbox('Campo Vac¡o',0,2,txt); end
                      else begin
                         txt[1]:='Los datos existentes son:';
                         txt[2]:='';
                         txt[3]:='Secci¢n: '+horarios[i].seccion;
                         txt[4]:='C¢digo de Curso: '+horarios[i].codigo;
                         txt[5]:='Nombre del Curso: '+nom;
                         txt[6]:='N£mero de Horas: '+strval(hor);
                         txt[7]:='Profesor: '+prof;
                         sw:=msgbox('Datos Existentes:',1,7,txt);
                      end;
                  until (prof<>'') and (sw=true);
                  horarios[i].profesor:=prof;
                  posit:=i;
                  cod:=horarios[i].codigo;
                  sec:=horarios[i].seccion;
                  tabla(0,1,cod,sec);
             end;
             2:begin
                  if hor<1 then begin
	                txt[1]:='El curso '+horarios[i].codigo+', con secci¢n '+horarios[i].seccion;
                     txt[2]:='inexistente en la base de datos'; end
                  else begin
	                txt[1]:='El curso '+nom;
                     txt[2]:='con profesor '+horarios[i].profesor+' y secci¢n '+horarios[i].seccion;
                  end;
                  txt[3]:='va a ser borrado.';
                  if msgbox('Borrar Curso y Secci¢n',1,3,txt)=false then exit;
                  horarios[i]:=horarios[totreghor];
                  dec(totreghor);
                  if totreghor>0 then SortHor(1,totreghor);
             end;
        end; end
     else begin
          out[1]:='';
          out[2]:='';
          repeat
              txt[1]:='N£mero de Secci¢n: '; max[1]:=4;
              txt[2]:='C¢digo de Curso:   '; max[2]:=5;
              gettext('Adicionar Curso',2,max,txt,out);
              if out[1]=#27 then exit;
              if (out[1]='') or (out[2]='') then begin
	            txt[1]:='No ha ingresado el n£mero';
                 txt[2]:='y/o el c¢digo de curso.';
                 msgbox('Datos Incompletos',0,2,txt);
              end;
          until (out[1]<>'') and (out[2]<>'');
          sec:=trim(out[1]);
          cod:=trim(out[2]);
          infocur(cod,nom,hor);
          if hor<1 then begin
             out[1]:=cod;
             editcur(3);
          end;
          infocur(cod,nom,hor);
          if hor<1 then exit;
          for i:=1 to totreghor do if (horarios[i].seccion=sec) and (horarios[i].codigo=cod) then begin
	         txt[1]:='El curso ingresado '+nom;
              txt[2]:='con secci¢n '+sec+' ya existe.';
              txt[3]:='S¢lo puede modificarlo o borrarlo.';
              msgbox('Curso ya Existe',0,3,txt);
              exit;
          end;
          posit:=totreghor+1;
          out[1]:='';
          repeat
              txt[1]:='Profesor: '; max[1]:=8;
              gettext('Curso: '+nom+', Secci¢n: '+sec,1,max,txt,out);
              if out[1]=#27 then exit;
              prof:=trim(out[1]);
              if prof='' then begin
	            txt[1]:='No ha ingresado el nombre';
                 txt[2]:='del profesor.';
                 msgbox('Campo Vac¡o',0,2,txt); end
              else begin
                 txt[1]:='Los datos existentes son:';
                 txt[2]:='';
                 txt[3]:='Secci¢n: '+sec;
                 txt[4]:='C¢digo de Curso: '+cod;
                 txt[5]:='Nombre del Curso: '+nom;
                 txt[6]:='N£mero de Horas: '+strval(hor);
                 txt[7]:='Profesor: '+prof;
                 sw:=msgbox('Datos Existentes:',1,7,txt);
              end;
          until (prof<>'') and (sw=true);
          with horarios[posit] do begin
               codigo:=cod;
               seccion:=sec;
               profesor:=prof;
               flag:='@';
               for j:=1 to 24 do hora[j]:=0;
          end;
          tabla(0,1,cod,sec);
          SortHor(1,totreghor);
     end;
end;

procedure infoarch;
var nom:string;
    i,hor,cont:integer;

begin
     if totreghor=0 then begin
	   txt[1]:='El archivo en uso no tiene';
        txt[2]:='secciones almacenadas.';
        msgbox('Archivo de Horario Vac¡o',0,2,txt);
        exit;
     end;
     ventcls(310,110,620,471,15,2,'Informaci¢n del Archivo');
     i:=0;
     cont:=0;
     settextstyle(2,0,4);
     setcolor(0);
     while i<totreghor do begin
          inc(i);
          if cont=0 then begin
             setcolor(0);
             outtextxy(335,140,'C¢digo    Nombre    Secci¢n  Profesor  Horas');
             setlinestyle(0,1,3);
             line(335,155,595,155);
          end;
          inc(cont);
          infocur(horarios[i].codigo,nom,hor);
          settextstyle(2,0,4);
          setcolor(4);
          if hor<1 then outtextxy(340,150+15*cont,horarios[i].codigo+space(7-
                   length(horarios[i].codigo))+'C¢digo no existe en la base de datos')
          else begin
             outtextxy(340,150+15*cont,horarios[i].codigo);
             outtextxy(380,150+15*cont,nom);
             outtextxy(470,150+15*cont,horarios[i].seccion);
             outtextxy(510,150+15*cont,horarios[i].profesor);
             outtextxy(580,150+15*cont,strval(hor));
          end;
          if (cont>0) and (cont mod 17=0) and (i<totreghor) then begin
             settextstyle(0,0,1);
             buton(355,430,230,25,0,'Pulse para Continuar . . .');
             buton(355,430,230,25,1,'Pulse para Continuar . . .');
             readkey;
             buton(355,430,230,25,2,'Pulse para Continuar . . .');
             delay(250);
             ventcls(310,110,620,471,15,2,'Informaci¢n del Archivo');
             cont:=0;
             settextstyle(2,0,4);
          end;
     end;
     settextstyle(0,0,1);
     buton(355,430,230,25,0,'Cerrar');
     buton(355,430,230,25,1,'Cerrar');
     readkey;
     buton(355,430,230,25,2,'Cerrar');
     delay(250);
     ventcls(310,110,620,471,15,2,'Informaci¢n');
end;

procedure infototcur;
var i,cont:integer;
    chkreg:regcur;

begin
     if totregcur=0 then begin
	   txt[1]:='La Base de Datos, archivo';
        txt[2]:='CURSOS.DAT, se encuentra vac¡a.';
        msgbox('Archivo de Cursos Vac¡o',0,2,txt);
        exit;
     end;
     ventcls(310,110,620,471,15,2,'Cursos en la Base de Datos');
     i:=0;
     cont:=0;
     settextstyle(2,0,4);
     setcolor(0);
     while i<totregcur do begin
          inc(i);
          if cont=0 then begin
             setcolor(0);
             outtextxy(365,140,'C¢digo      Nombre         Horas');
             setlinestyle(0,1,3);
             line(335,155,595,155);
          end;
          inc(cont);
          setcolor(4);
          with cursos[i] do begin
               outtextxy(370,150+15*cont,codigo);
               outtextxy(430,150+15*cont,nombre);
               outtextxy(540,150+15*cont,strval(ht));
          end;
          if (cont mod 17=0) and (i<totregcur) and (cont<>0) then begin
             settextstyle(0,0,1);
             buton(355,430,230,25,0,'Pulse para Continuar . . .');
             buton(355,430,230,25,1,'Pulse para Continuar . . .');
             readkey;
             buton(355,430,230,25,2,'Pulse para Continuar . . .');
             delay(250);
             ventcls(310,110,620,471,15,2,'Cursos en la Base de Datos');
             cont:=0;
             settextstyle(2,0,4);
          end;
     end;
     settextstyle(0,0,1);
     buton(355,430,230,25,0,'Cerrar');
     buton(355,430,230,25,1,'Cerrar');
     readkey;
     buton(355,430,230,25,2,'Cerrar');
     delay(250);
     ventcls(310,110,620,471,15,2,'Informaci¢n');
end;

procedure infonom;

begin
     ventcls(310,28,620,100,15,1,'Archivo Abierto');
     settextstyle(2,0,4);
     setcolor(0);
     outtextxy(320,55,'Archivo en uso:');
     setcolor(4);
     if archhor<>'' then outtextxy(320,70,+archhor) else
        outtextxy(320,70,'No hay archivo de Horario abierto.');
     settextstyle(0,0,1);
end;

procedure about;

begin
     txt[1]:='Generador de Horarios';
     txt[2]:='versi¢n Beta96';
     txt[3]:='';
     txt[4]:='Programado por:';
     txt[5]:='Oscar Zamora Plasencia';
     txt[6]:='';
     txt[7]:='ZmS Software, (C) 1995 - 1996';
     msgbox('Acerca del Programa',0,7,txt);
end;

procedure ayuda;
var help:text;
    line,search:string;
    i,j:integer;

begin
	{$I-}
     assign(help,'gdh.hlp');
     reset(help);
     {$I+}
     if IOResult<>0 then begin
	   txt[1]:='Archivo de ayuda no existe.';
        msgbox('Archivo Inexistente',0,1,txt);
        exit;
     end;
     line:=' ';
     j:=0;
     while (not seekeof(help)) and (not (line[1]='0')) do begin
           readln(help,line);
           if line[1]<>'0' then begin
              inc(j);
              selopt[j]:=line;
           end;
     end;
     selectitem('Ayuda: Selecci¢n de T¢pico',j,1,selopt,tomaitem);
     if tomaitem[0]=true then exit;
     i:=1;
     while tomaitem[i]=false do inc(i);
     if i<10 then search:='00'+alltrim(strval(i)) else
        search:='0'+alltrim(strval(i));
     reset(help);
     repeat
          readln(help,line);
     until (line=search) or (seekeof(help));
     ventana(20,25,620,470,15,1,'Ayuda: '+selopt[i]);
     line:=' ';
     i:=0;
     setcolor(0);
     while (not seekeof(help)) and (not (line[1]='0')) do begin
          inc(i);
          readln(help,line);
          if line[1]<>'0' then begin
             outtextxy(35,50+14*i,line);
          end;
     end;
     buton(500,430,100,25,0,'Cerrar');
     buton(500,430,100,25,1,'Cerrar');
     readkey;
     buton(500,430,100,25,2,'Cerrar');
     delay(250);
     close(help);
     refresh;
end;

function salir:boolean;

begin
     txt[1]:='¨Des‚a Terminar con el Programa?';
     salir:=msgbox('Salir del Programa',1,1,txt);
end;

procedure menu;
var sel,antsel,max:integer;
    key:char;
    sw:boolean;
    antarch:string;
    i:integer;

begin
     assign(cuadres,'gdh.tmp');
     rewrite(cuadres);
     posibles:=false;
     for i:=1 to 375 do tomaitem[i]:=false;
     archhor:='';
     sel:=1;
     antsel:=1;
     max:=14;
     repeat
          if antarch<>archhor then begin
             infonom;
             antarch:=archhor;
          end;
          buton(30,30+29*antsel,250,25,3,mn[antsel]);
          buton(30,30+29*sel,250,25,1,mn[sel]);
          key:=readkey;
          antsel:=sel;
          case key of
          	#9:if sel=max then sel:=1 else inc(sel);
               #27:if salir=true then exit;
			#13,#32:begin
               	buton(30,30+29*sel,250,25,2,mn[sel]);
                    delay(250);
				buton(30,30+29*sel,250,25,0,mn[sel]);
                    if sel in[1..4,8..10,12] then begin
                       for i:=1 to 375 do tomaitem[i]:=false;
                       if sel<>12 then posibles:=false;
                    end;
                    if (archhor='') and (sel in [2..7]) then begin
	                  txt[1]:='No existe ning£n nombre de';
                       txt[2]:='archivo activo en memoria.';
                       txt[3]:='Cree o cargue un archivo.';
                       msgbox('Sin archivo activo',0,3,txt); end
                    else begin
                      sw:=true;
                      case sel of
                         1:abrehor;
                         2:edithor(0);
                         3:edithor(1);
                         4:edithor(2);
                         5:infoarch;
                         6:genera;
                         7:impcuadres;
                         8:editcur(0);
                         9:editcur(1);
                         10:editcur(2);
                         11:infototcur;
                         12:ayuda;
                         13:about;
                         14:if salir=true then exit;
                      end;
                    end;
                    if sel in[3,4,9,10,12] then for i:=1 to 375 do tomaitem[i]:=false;
               end;
			#0:begin key:=readkey;
               	case key of
                         #59:ayuda;
					#15,#72,#75:if sel=1 then sel:=max else dec(sel);
                         #77,#80:if sel=max then sel:=1 else inc(sel);
                    end;
               end;
     	end;
	until false;
end;

procedure InicGraficos;
var	i,mode,control,errcode:Integer;

begin
	mode:=9;
     control:=2;
     Initgraph(mode,control,'c:\util\leng\tpascal\bgi');
     errcode := graphresult;
     if errcode <> grok then begin
        clrscr;
        beep;
        writeln(GraphErrorMsg(ErrCode));
        writeln('No se puede inicializar, manejador VGA requerido.');
        halt;
     end;
     ventana(0,0,getmaxx,getmaxy,3,9,'Generador de Horarios');
     abrecur;
     refresh;
     menu;
     closegraph;
     writeln('Generador de Horarios vBeta96.');
     rewrite(filecur);
     for i:=1 to totregcur do begin
         seek(filecur,i);
         write(filecur,cursos[i]);
     end;
     acthorario;
end;

begin
	InicGraficos;
     close(filecur);
     if archhor<>'' then close(filehor);
     close(cuadres);
     erase(cuadres);
end.