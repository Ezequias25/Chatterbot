Unit informacion;
{$H+}

{ ================================================================ }
{  Informacion.pas - Estadisticas generales de la base            }
{  Todo con arrays y variables LOCALES, sin break/exit/halt.       }
{ ================================================================ }

Interface

Uses sysutils, archivo;

Const
  MAXB = 60;   { cantidad maxima de "cubetas" para acumular nombres }

Type
  TCampo4 = array[1..4] Of String;
  TNombres = array[1..MAXB] Of String;
  TSumas = array[1..MAXB] Of LongInt;

Procedure TotalPeliculas(Var f: TextFile; Var cant: Integer);
Procedure ContarDirector(Var f: TextFile; nombre: String; Var cant: Integer);
Procedure ContarActor(Var f: TextFile; nombre: String; Var cant: Integer);

Procedure DirectorMasPeliculas(Var f: TextFile; Var nombre: String;
                              Var cant: Integer);
Procedure ActorMasPeliculas(Var f: TextFile; Var nombre: String;
                           Var cant: Integer);
Procedure GeneroMasPeliculas(Var f: TextFile; Var genero: String;
                            Var cant: Integer);

Procedure PeliculaMasVista(Var f: TextFile; Var peli: TPelicula; Var enc: Boolean);
Procedure PeliculaMasIngresos(Var f: TextFile; Var peli: TPelicula;
                             Var enc: Boolean);
Procedure GeneroMasIngresos(Var f: TextFile; Var genero: String;
                           Var ingresos: LongInt);

Implementation

{ Parte un campo por comas en hasta 4 pedazos }
Procedure PartirCampo(campo: String; Var partes: TCampo4;
                      Var n: Integer);
Var resta, pedazo: String;
    posComa: Integer;
Begin
  n := 0;
  resta := campo;
  While (Length(resta) > 0) And (n < 4) Do
    Begin
      posComa := Pos(',', resta);
      If posComa > 0 Then
        Begin
          pedazo := Trim(Copy(resta, 1, posComa - 1));
          resta := Trim(Copy(resta, posComa + 1, Length(resta)));
        End
      Else
        Begin
          pedazo := Trim(resta);
          resta := '';
        End;
      If Length(pedazo) > 0 Then
        Begin
          Inc(n);
          partes[n] := pedazo;
        End;
    End;
End;

Procedure TotalPeliculas(Var f: TextFile; Var cant: Integer);
Var linea: String;
Begin
  cant := 0;
  Reset(f);
  While (Not Eof(f)) Do
    Begin
      ReadLn(f, linea);
      Inc(cant);
    End;
End;

Procedure ContarDirector(Var f: TextFile; nombre: String; Var cant: Integer);
Var linea: String;
    peli: TPelicula;
Begin
  cant := 0;
  Reset(f);
  While (Not Eof(f)) Do
    Begin
      ReadLn(f, linea);
      ObtenerDatos(linea, peli);
      If Pos(LowerCase(nombre), LowerCase(peli.director)) > 0 Then
        Inc(cant);
    End;
End;

Procedure ContarActor(Var f: TextFile; nombre: String; Var cant: Integer);
Var linea: String;
    peli: TPelicula;
Begin
  cant := 0;
  Reset(f);
  While (Not Eof(f)) Do
    Begin
      ReadLn(f, linea);
      ObtenerDatos(linea, peli);
      If Pos(LowerCase(nombre), LowerCase(peli.actor)) > 0 Then
        Inc(cant);
    End;
End;

{ Acumula un nombre en un arreglo de cubetas; si existe suma, si no agrega }
Procedure AcumularNombre(Var nombres: TNombres;
                         Var cantidades: TSumas;
                         Var nB: Integer; nombre: String);
Var i: Integer;
    enc: Boolean;
Begin
  enc := False;
  i := 1;
  While (i <= nB) And (Not enc) Do
    Begin
      If nombres[i] = nombre Then
        Begin
          Inc(cantidades[i]);
          enc := True;
        End;
      Inc(i);
    End;
  If (Not enc) And (nB < MAXB) Then
    Begin
      Inc(nB);
      nombres[nB] := nombre;
      cantidades[nB] := 1;
    End;
End;

Procedure DirectorMasPeliculas(Var f: TextFile; Var nombre: String;
                              Var cant: Integer);
Var
  nombres: TNombres;
  cantidades: TSumas;
  nB, i, j, npartes, h: Integer;
  partes: TCampo4;
  linea: String;
  peli: TPelicula;
  dir: String;
Begin
  nB := 0;
  Reset(f);
  While (Not Eof(f)) Do
    Begin
      ReadLn(f, linea);
      ObtenerDatos(linea, peli);
      PartirCampo(peli.director, partes, npartes);
      For h := 1 To npartes Do
        Begin
          dir := LowerCase(Trim(partes[h]));
          AcumularNombre(nombres, cantidades, nB, dir);
        End;
    End;

  cant := 0;
  nombre := '';
  For j := 1 To nB Do
    If cantidades[j] > cant Then
      Begin
        cant := cantidades[j];
        nombre := nombres[j];
      End;
End;

Procedure ActorMasPeliculas(Var f: TextFile; Var nombre: String;
                           Var cant: Integer);
Var
  nombres: TNombres;
  cantidades: TSumas;
  nB, i, j, npartes, h: Integer;
  partes: TCampo4;
  linea: String;
  peli: TPelicula;
  act: String;
Begin
  nB := 0;
  Reset(f);
  While (Not Eof(f)) Do
    Begin
      ReadLn(f, linea);
      ObtenerDatos(linea, peli);
      PartirCampo(peli.actor, partes, npartes);
      For h := 1 To npartes Do
        Begin
          act := LowerCase(Trim(partes[h]));
          AcumularNombre(nombres, cantidades, nB, act);
        End;
    End;

  cant := 0;
  nombre := '';
  For j := 1 To nB Do
    If cantidades[j] > cant Then
      Begin
        cant := cantidades[j];
        nombre := nombres[j];
      End;
End;

Procedure GeneroMasPeliculas(Var f: TextFile; Var genero: String;
                            Var cant: Integer);
Var
  nombres: TNombres;
  cantidades: TSumas;
  nB, j, npartes, h: Integer;
  partes: TCampo4;
  linea: String;
  peli: TPelicula;
  gen: String;
Begin
  nB := 0;
  Reset(f);
  While (Not Eof(f)) Do
    Begin
      ReadLn(f, linea);
      ObtenerDatos(linea, peli);
      PartirCampo(peli.genero, partes, npartes);
      For h := 1 To npartes Do
        Begin
          gen := LowerCase(Trim(partes[h]));
          AcumularNombre(nombres, cantidades, nB, gen);
        End;
    End;

  cant := 0;
  genero := '';
  For j := 1 To nB Do
    If cantidades[j] > cant Then
      Begin
        cant := cantidades[j];
        genero := nombres[j];
      End;
End;

Procedure PeliculaMasVista(Var f: TextFile; Var peli: TPelicula; Var enc: Boolean);
Var linea: String;
    temp: TPelicula;
Begin
  enc := False;
  Reset(f);
  While (Not Eof(f)) Do
    Begin
      ReadLn(f, linea);
      ObtenerDatos(linea, temp);
      If (Not enc) Or (temp.vistas > peli.vistas) Then
        Begin
          enc := True;
          peli := temp;
        End;
    End;
End;

Procedure PeliculaMasIngresos(Var f: TextFile; Var peli: TPelicula;
                             Var enc: Boolean);
Var linea: String;
    temp: TPelicula;
Begin
  enc := False;
  Reset(f);
  While (Not Eof(f)) Do
    Begin
      ReadLn(f, linea);
      ObtenerDatos(linea, temp);
      If (Not enc) Or (temp.ingresos > peli.ingresos) Then
        Begin
          enc := True;
          peli := temp;
        End;
    End;
End;

Procedure GeneroMasIngresos(Var f: TextFile; Var genero: String;
                           Var ingresos: LongInt);
Var
  nombres: TNombres;
  sumas: TSumas;
  nB, i, j, npartes, h: Integer;
  partes: TCampo4;
  linea: String;
  peli: TPelicula;
  gen: String;
  enc: Boolean;
Begin
  nB := 0;
  Reset(f);
  While (Not Eof(f)) Do
    Begin
      ReadLn(f, linea);
      ObtenerDatos(linea, peli);
      PartirCampo(peli.genero, partes, npartes);
      For h := 1 To npartes Do
        Begin
          gen := LowerCase(Trim(partes[h]));
          enc := False;
          i := 1;
          While (i <= nB) And (Not enc) Do
            Begin
              If nombres[i] = gen Then
                Begin
                  sumas[i] := sumas[i] + peli.ingresos;
                  enc := True;
                End;
              Inc(i);
            End;
          If (Not enc) And (nB < MAXB) Then
            Begin
              Inc(nB);
              nombres[nB] := gen;
              sumas[nB] := peli.ingresos;
            End;
        End;
    End;

  ingresos := 0;
  genero := '';
  For j := 1 To nB Do
    If sumas[j] > ingresos Then
      Begin
        ingresos := sumas[j];
        genero := nombres[j];
      End;
End;

End.