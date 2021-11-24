PROGRAM seconde_partie;

{Constantes demandées par le sujet}
CONST
	N=20;
	M=N*N+1;                              {On ajoute 1 pour simplifier et accélerer le traitement des données en entrée}
	ENERGIE=4;
	AGE_MORT=5;
	ENERGIE_REPRODUCTION=10;
	ENERGIE_INITIALE=1;
	
{Types demandés par le sujet}
TYPE
	herbe= Record age,energy : integer; vie: boolean; End;
	position=Record x,y:integer; End;
	typeGeneration= array[0..N-1,0..N-1] of herbe;
	typelistePosition=array[0..M-1] of position;
	typeParametres=Record i,o:string; End;                              {TypeParametres permet de stocker les nom des fichiers associés aux commandes -i et -o}

{Variables locales}
var
	lipo:typelistePosition;
	gen:typegeneration;
	ite:integer;                              {ite sert à stocker le nombre d'itérations souhaitées par l'utilisateur}
	p:string;                              {p sert à empecher le programe de se fermer une fois terminé}
	Para:typeParametres;                              {Para permet de stocker les nom des fichiers associés aux commandes -i et -o}

{Fonction servant a placer des célules stockées dans une liste, dans une grille de taille N*N}
FUNCTION initialiserGeneration(listePositions:typelistePosition):typeGeneration;
var i,k:integer;sortida:typeGeneration;
Begin
	for i:=0 to N-1 do
		for k:=0 to N-1 do
			Begin                              {Premièrement on initialise toutes les celules de la grille}
			sortida[i][k].energy:=0;
			sortida[i][k].age:=0;
			sortida[i][k].vie:=False;
			End;
	k:=listePositions[0].x;                              {On se sert de listePosition[0].x pour stocker le nombre de célules ayant étées initialisées}
	for i:= 1 to k do
		Begin
		sortida[listePositions[i].y][listePositions[i].x].energy:=ENERGIE_INITIALE;
		sortida[listePositions[i].y][listePositions[i].x].age:=0;
		sortida[listePositions[i].y][listePositions[i].x].vie:=True;
		End;
   initialiserGeneration:= sortida;                              {On renvoie la grille initialisée}
End;

{Cette Fonction Permet dans le cas ou l'utilisateur ne désire pas charger de fichier de sauvegarde d'initialiser manuelement la grille}
FUNCTION entreclavier:typelisteposition;
var i,j:integer;sortie:typelistePosition;k:boolean;
Begin
	k:=true;
	write('Combien de cellules initiales souhaitez vous ?');writeln;
	write('saisissez un nombre inférieur à ', M-1);writeln;
	while k=true do Begin
		readln(j);
		if j<M then                              {Cette condition verifie si l'utilisateur à entré une valeure infèrieure a M-1}
			k:=false;
		End;
	sortie[0].x:=j;
	for i:= 1 to j do Begin
		writeln('Saisissez l''abscisse de l''herbe numero ',i);
		readln(sortie[i].x);
		 sortie[i].x:=sortie[i].x mod N;                              {Cette ligne là ainsi que la suivant permettent de saisir n'importe quel nombre positif ou négatif (vu qu'il s'agit d'une grille torique)}
        if sortie[i].x <0 then sortie[i].x:=sortie[i].x+N;	
		writeln('Saisissez l''ordonée de l''herbe numero ',i);
		readln(sortie[i].y);
		sortie[i].y:=sortie[i].y mod N;                              {même chose}
        if sortie[i].y <0 then sortie[i].y:=sortie[i].y+N;	
		writeln('Il vous reste ',j-i,' valeures à saisir (',(j-i)*2 ,' entrées clavier)');
		End;
	entreclavier:=sortie;
End;

{Cette fonction affiche l'état actuel d'une génération}
Function afficherGeneration(generation:typeGeneration):typeGeneration;
var i,j:integer; 
begin
	i:=0;
	j:=0;
	for i:=0 to N-1 do
		Begin
		for j:=0 to N-1 do	
			if generation[i,j].vie=true then
				write(' h')
			else
				write(' .');
		writeln;
		End;
	afficherGeneration:=generation;
End;

{Cette fontion teste si les cellules voisines à celle dont les coordonées sont entrées en parametre sont vivantes, si oui elle les initialise}
Function calcemptycels(x,y:integer;generation:typeGeneration):typeGeneration;
var i,j,k,l,m:integer;gen1:typeGeneration;
Begin
	gen1:=generation; m:=0;
    for i :=-1 to 1 do
        Begin
        k:=(x+i) mod N;
        if k <0 then k:=k+N;	
        for j:=-1 to 1 do
            Begin
                l:=(y+j) mod N;
                if l <0 then l:=l+N;	
                if generation[k][l].vie=False then Begin
                    gen1[k][l].vie:=True; gen1[k][l].energy:=ENERGIE_INITIALE;gen1[k][l].age:=0;m+=1;End;
            End;
    End;
        if m>0 then gen1[y][x].energy-=10;
        calcemptycels:=gen1;
End;

{Cette fonction execute le jeu de la vie un certain nombre de fois}
Function runGeneration(generation:typeGeneration;nombreIteration:integer):typeGeneration;
var t,i,j,k:integer;gen1,gen2:typeGeneration;
Begin
	gen1:=generation; gen2:=generation;
	for t:=0 to nombreIteration-1 do
        Begin for i:=0 to N-1 do
            Begin for j:=0 to N-1 do Begin
                	If gen1[i][j].vie=True then
                        Begin
                        if gen1[i][j].age<5 then gen2[i][j].age+=1 else gen2[i][j].vie:=False;
                        if gen1[i][j].energy>10 then gen2:=calcemptycels(i,j,gen2) else gen2[i][j].energy+=ENERGIE;                              {si l'herbe a plus de 10 d'énergie on execute la fonction calcemptycels}
                        End;End;End;
                        gen1:=gen2 ;
                        write('Itération n°',t+1);writeln;
                        afficherGeneration(gen1);
                        End;
                        runGeneration:=gen1;
End;

{Cette fonction enregistre dans un fichier texte les valeures des variables de l'utilisateur avec les critères esthétiques demandés}
Function sauvegarde(generation:typeGeneration;fichier:string;iterations:integer):string;
var i,j,l:integer;f: text;k:string;
Begin
	l:=0;
	assign(f,fichier);
    rewrite(f);
    write(f,'ViePosition = [');
	for i:=0 to N-1 do
        for j:=0 to N-1 do
            if generation[j][i].vie=True then begin
            	if l>0 then write(f,' '); l+=1; 
                write(f,'('); str(j,k); write(f,k); write(f,',');
                str(i,k); write(f,k); write(f,')'); end;
    write(f,']NombreGeneration = ');
    str(iterations,k); write(f,k);
    close(f);
End;

{Cette fonction détermine les différents arguments et les ordonne, c'est aussi la fonction qui permet la non positionalitée des arguments}
Function TriParametres:typeParametres;
var i:integer; typa1:typeParametres; j,k:boolean;
Begin;
j:=False; k:=False;
if ParamCount>0 then Begin
    for i:=1 to ParamCount do
        if ParamStr (i)='-i' then Begin typa1.i:=ParamStr (i+1);k:=True End 
        else 
            if ParamStr (i)='-o' then Begin typa1.o:=ParamStr (i+1);j:=True End;
    End;
if j=False then typa1.o:='0'; 
if k=False then typa1.i:='0';
 TriParametres:=typa1;
End;

{Cette fonction est censée "charger" les valeures sauvegardées dans le fichier mentioné après le -i}
{Toutefois cette fonction ne s'execute pas corectement et place aléatoirement les éléments}
{ si elle est quand même présente c'est que sa présence est nescessaire pour démontrer le bon fonctionement des autres fonctions}
Function chargement(NomFichier:string):typelistePosition;
var fichier:text; c,d:char; i,j,m:integer;lipo1:typelistePosition; s:string;
Begin
	assign(fichier,NomFichier); reset(fichier); m:=0;
	while not eof (fichier) do begin
		while not eoln (fichier) do begin 
			read (fichier,c);
			if c='[' then begin
				repeat begin
                    read(fichier,c); read(fichier,c); read(fichier,d);
                    if d<>',' then begin
                        s:=c+d; val(s,i); read(fichier,c); read(fichier,c); read(fichier,d);
                        if d<>')' then begin 
                            s:=c+d; val(s,j); read(fichier,c); read(fichier,c) end
                        else begin 
                        	s:=c; val(s,j); read(fichier,c) end;end
                    else begin
                        s:=c; val(s,i); read(fichier,c); read(fichier,c);
                        if d<>')' then begin
                            s:=c+d; val(s,j); read(fichier,c); read(fichier,c) end
                        else begin 
                        	s:=c; val(s,j); read(fichier,c) end;
                    end; m+=1; lipo1[m].x:=i; lipo1[m].y:=j; end; 
                until c=']';
        lipo1[0].x:=m; end; end; end; s:=c; val(s,m); lipo1[0].y:=m; close (fichier); chargement:=lipo1;
End;

BEGIN
para:=TriParametres;
if para.i='0' then Begin                              {Test si des arguments d'entrée ont été saisis}
	{si non}
	lipo:=entreclavier;
	gen:=initialiserGeneration(lipo); End
else Begin
	{si oui}
    lipo:=chargement(para.i);
    gen:=initialiserGeneration(lipo); End;
    
gen:=afficherGeneration(gen);

write('Combien d''itérations souhaitez vous ?');
read(ite);

if ite>0 then begin
    gen:=runGeneration(gen,ite);
    if para.o<>'0' then sauvegarde(gen,para.o,ite); end;                              {Test si des arguments de sortie ont été saisis}
    
read(p);
END.