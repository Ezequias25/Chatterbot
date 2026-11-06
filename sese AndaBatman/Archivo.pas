Unit archivo;
{$H+}

{ ================================================================ }
{  Archivo.pas - Lectura y busquedas sobre la base de datos        }
{  Formato por linea:                                              }
{  Titulo|Director|Genero|Actores|Anio|Franquicia|Etiquetas|       }
{  Ingresos|Vistas|TotalSaga                                       }
{  Sin break, sin exit, sin halt. Todo con banderas booleanas.     }
{ ================================================================ }

Interface

Uses sysutils, palabras_claves;

Const
  MAXCAND = 30;

Type
  TPelicula = Record
    titulo: String;
    director: String;
    genero: String;
    actor: String;
    anio: String;
    franquicia: String;
    etiquetas: String;
    ingresos: LongInt;
    vistas: LongInt;
    totalSaga: LongInt;
  End;

  TListaPelis = array[1..MAXCAND] Of TPelicula;
  TLineaPelis = array[1..MAXCAND] Of String;

Procedure ObtenerDatos(linea: String; Var peli: TPelicula);
Procedure NormalizarClave(s: String; Var res: String);

Procedure BuscarPorGenero(Var f: TextFile; gen: String; Var pelis: String;
                          Var cant: Integer);
Procedure BuscarPorAnio(Var f: TextFile; anio: String; Var pelis: String;
                        Var cant: Integer);
Procedure BuscarPorRangoAnios(Var f: TextFile; desde, hasta: Integer;
                              Var pelis: String; Var cant: Integer);
Procedure BuscarPorActor(Var f: TextFile; nom: String; Var pelis: String;
                         Var cant: Integer);
Procedure BuscarPorDirector(Var f: TextFile; nom: String; Var pelis: String;
                            Var cant: Integer);
Procedure BuscarPorFranquicia(Var f: TextFile; franq: String; Var pelis: String;
                              Var cant: Integer);
Procedure BuscarParecidas(Var f: TextFile; frag: String; Var pelis: String;
                          Var cant: Integer);
Procedure TotalFranquicia(Var f: TextFile; franq: String; Var total: LongInt);

Procedure PeliculaAlAzar(Var f: TextFile; gen, ep: String; desde, hasta: Integer;
                         mostradas: String; Var peli: TPelicula; Var enc: Boolean);

Procedure FormatearLista(pelis: String; Var salida: String);
Procedure FormatearUna(peli: TPelicula; Var salida: String);
Procedure SepararLista(pelis: String; Var lista: TListaPelis;
                       Var lineas: TLineaPelis; Var cant: Integer);

Procedure AgregarPeliculaMostrada(Var mostradas: String; peli: TPelicula);
Function PeliculaYaMostrada(mostradas: String; peli: TPelicula): Boolean;
Procedure ClavePelicula(peli: TPelicula; Var clave: String);

Implementation

Function LimpiarLinea(linea: String): String;
Begin
  If (Length(linea) > 0) And (linea[Length(linea)] = #13) Then
    LimpiarLinea := Copy(linea, 1, Length(linea) - 1)
  Else
    LimpiarLinea := linea;
End;

Procedure ObtenerDatos(linea: String; Var peli: TPelicula);
Var
  campos: array[1..10] Of String;
  i, posDelim: Integer;
Begin
  linea := LimpiarLinea(linea);
  For i := 1 To 10 Do
    Begin
      posDelim := Pos('|', linea);
      If posDelim > 0 Then
        Begin
          campos[i] := Trim(Copy(linea, 1, posDelim - 1));
          Delete(linea, 1, posDelim);
        End
      Else
        campos[i] := Trim(linea);
    End;

  peli.titulo := campos[1];
  peli.director := campos[2];
  peli.genero := campos[3];
  peli.actor := campos[4];
  peli.anio := campos[5];
  peli.franquicia := campos[6];
  peli.etiquetas := campos[7];
  peli.ingresos := StrToInt(campos[8]);
  peli.vistas := StrToInt(campos[9]);
  peli.totalSaga := StrToInt(campos[10]);
End;

{ Quita espacios, guiones y guiones bajos: "harry potter", "harry_potter" }
{ y "harry-poter" quedan todos como "harrypotter"                        }
Procedure NormalizarClave(s: String; Var res: String);
Var i: Integer;
Begin
  res := '';
  For i := 1 To Length(s) Do
    If (s[i] <> ' ') And (s[i] <> '_') And (s[i] <> '-') Then
      res := res + LowerCase(s[i]);
End;

Procedure AgregarCoincidencia(Var pelis: String; Var cant: Integer;
                              linea: String);
Begin
  If cant < MAXCAND Then
    Begin
      pelis := pelis + linea + #13#10;
      Inc(cant);
    End;
End;

Procedure BuscarPorGenero(Var f: TextFile; gen: String; Var pelis: String;
                          Var cant: Integer);
Var linea: String;
    peli: TPelicula;
Begin
  pelis := '';
  cant := 0;
  Reset(f);
  While (Not Eof(f)) Do
    Begin
      ReadLn(f, linea);
      ObtenerDatos(linea, peli);
      If Pos(gen, peli.genero) > 0 Then
        AgregarCoincidencia(pelis, cant, linea);
    End;
End;

Procedure BuscarPorAnio(Var f: TextFile; anio: String; Var pelis: String;
                        Var cant: Integer);
Var linea: String;
    peli: TPelicula;
Begin
  pelis := '';
  cant := 0;
  Reset(f);
  While (Not Eof(f)) Do
    Begin
      ReadLn(f, linea);
      ObtenerDatos(linea, peli);
      If peli.anio = anio Then
        AgregarCoincidencia(pelis, cant, linea);
    End;
End;

Procedure BuscarPorRangoAnios(Var f: TextFile; desde, hasta: Integer;
                              Var pelis: String; Var cant: Integer);
Var linea: String;
    peli: TPelicula;
    anioNum: LongInt;
Begin
  pelis := '';
  cant := 0;
  Reset(f);
  While (Not Eof(f)) Do
    Begin
      ReadLn(f, linea);
      ObtenerDatos(linea, peli);
      anioNum := StrToInt(peli.anio);
      If (anioNum >= desde) And (anioNum <= hasta) Then
        AgregarCoincidencia(pelis, cant, linea);
    End;
End;

Procedure BuscarPorActor(Var f: TextFile; nom: String; Var pelis: String;
                         Var cant: Integer);
Var linea: String;
    peli: TPelicula;
Begin
  pelis := '';
  cant := 0;
  Reset(f);
  While (Not Eof(f)) Do
    Begin
      ReadLn(f, linea);
      ObtenerDatos(linea, peli);
      If Pos(LowerCase(nom), LowerCase(peli.actor)) > 0 Then
        AgregarCoincidencia(pelis, cant, linea);
    End;
End;

Procedure BuscarPorDirector(Var f: TextFile; nom: String; Var pelis: String;
                            Var cant: Integer);
Var linea: String;
    peli: TPelicula;
Begin
  pelis := '';
  cant := 0;
  Reset(f);
  While (Not Eof(f)) Do
    Begin
      ReadLn(f, linea);
      ObtenerDatos(linea, peli);
      If Pos(LowerCase(nom), LowerCase(peli.director)) > 0 Then
        AgregarCoincidencia(pelis, cant, linea);
    End;
End;

Procedure BuscarPorFranquicia(Var f: TextFile; franq: String; Var pelis: String;
                              Var cant: Integer);
Var linea, nFq, nCampo: String;
    peli: TPelicula;
Begin
  pelis := '';
  cant := 0;
  NormalizarClave(franq, nFq);
  Reset(f);
  While (Not Eof(f)) Do
    Begin
      ReadLn(f, linea);
      ObtenerDatos(linea, peli);
      NormalizarClave(peli.franquicia, nCampo);
      If Pos(nFq, nCampo) > 0 Then
        AgregarCoincidencia(pelis, cant, linea);
    End;
End;

Procedure TotalFranquicia(Var f: TextFile; franq: String; Var total: LongInt);
Var linea, nFq, nCampo: String;
    peli: TPelicula;
    encontrado: Boolean;
Begin
  total := 0;
  NormalizarClave(franq, nFq);
  encontrado := False;
  Reset(f);
  While (Not Eof(f)) And (Not encontrado) Do
    Begin
      ReadLn(f, linea);
      ObtenerDatos(linea, peli);
      NormalizarClave(peli.franquicia, nCampo);
      If Pos(nFq, nCampo) > 0 Then
        Begin
          total := peli.totalSaga;
          encontrado := True;
        End;
    End;
End;

{ Separa un fragmento en hasta 3 palabras significativas }
Procedure SepararPalabras(frag: String; Var p1, p2, p3: String; Var n: Integer);
Var
  resta, palabra: String;
  posEsp, intentos, i: Integer;
  esStop: Boolean;
Begin
  p1 := '';
  p2 := '';
  p3 := '';
  n := 0;
  resta := Trim(frag);
  intentos := 0;
  While (Length(resta) > 0) And (n < 3) And (intentos < 20) Do
    Begin
      posEsp := Pos(' ', resta);
      If posEsp = 0 Then
        Begin
          palabra := resta;
          resta := '';
        End
      Else
        Begin
          palabra := Copy(resta, 1, posEsp - 1);
          resta := Copy(resta, posEsp + 1, Length(resta));
        End;
      esStop := False;
      For i := 1 To CANT_STOPWORDS Do
        If palabra = stopwords[i] Then
          esStop := True;
      If (Not esStop) And (Length(palabra) >= 2) Then
        Begin
          Inc(n);
          If n = 1 Then
            p1 := LowerCase(palabra)
          Else If n = 2 Then
                 p2 := LowerCase(palabra)
          Else
            p3 := LowerCase(palabra);
        End;
      Inc(intentos);
    End;
End;

{ Cada pelicula matchea si TODAS las palabras del fragmento aparecen }
{ en sus campos (titulo, director, genero, actores, franquicia, tags) }
Procedure BuscarParecidas(Var f: TextFile; frag: String; Var pelis: String;
                          Var cant: Integer);
Var
  linea, p1, p2, p3, todos: String;
  n, i: Integer;
  peli: TPelicula;
  cumple: Boolean;
Begin
  pelis := '';
  cant := 0;
  SepararPalabras(frag, p1, p2, p3, n);
  If n > 0 Then
    Begin
      Reset(f);
      While (Not Eof(f)) Do
        Begin
          ReadLn(f, linea);
          ObtenerDatos(linea, peli);
          todos := LowerCase(peli.titulo) + ' ' + LowerCase(peli.director) + ' ' +
                   LowerCase(peli.genero) + ' ' + LowerCase(peli.actor) + ' ' +
                   LowerCase(peli.franquicia) + ' ' + LowerCase(peli.etiquetas);
          cumple := True;
          If (Pos(p1, todos) = 0) Then
            cumple := False;
          If cumple And (n >= 2) Then
            If (Pos(p2, todos) = 0) Then
              cumple := False;
          If cumple And (n >= 3) Then
            If (Pos(p3, todos) = 0) Then
              cumple := False;
          If cumple Then
            AgregarCoincidencia(pelis, cant, linea);
        End;
    End;
End;

{__PARTE2__}

Procedure PeliculaAlAzar(Var f: TextFile; gen, ep: String; desde, hasta: Integer;
                         mostradas: String; Var peli: TPelicula; Var enc: Boolean);
Var
  linea: String;
  totalLineas, i, intentos, lineaElegida: Integer;
  anioNum: LongInt;
  cumple: Boolean;
Begin
  enc := False;
  totalLineas := 0;
  Reset(f);
  While (Not Eof(f)) Do
    Begin
      ReadLn(f, linea);
      Inc(totalLineas);
    End;

  If totalLineas > 0 Then
    Begin
      intentos := 0;
      While (Not enc) And (intentos < 100) Do
        Begin
          lineaElegida := Random(totalLineas) + 1;
          Reset(f);
          For i := 1 To lineaElegida Do
            ReadLn(f, linea);
          ObtenerDatos(linea, peli);

          cumple := True;
          If (Length(gen) > 0) Then
            If Pos(gen, peli.genero) = 0 Then
              cumple := False;

          If cumple And (Length(ep) > 0) Then
            Begin
              anioNum := StrToInt(peli.anio);
              If (anioNum < desde) Or (anioNum > hasta) Then
                cumple := False;
            End;

          If cumple Then
            If PeliculaYaMostrada(mostradas, peli) Then
              cumple := False;

          If cumple Then
            enc := True;

          Inc(intentos);
        End;
    End;
End;

{ Convierte una cadena con varias lineas separadas por #13#10 en una lista }
Procedure SepararLista(pelis: String; Var lista: TListaPelis;
                       Var lineas: TLineaPelis; Var cant: Integer);
Var
  temp, linea: String;
  posSalto: Integer;
Begin
  cant := 0;
  temp := pelis;
  While (Length(temp) > 0) And (cant < MAXCAND) Do
    Begin
      posSalto := Pos(#13#10, temp);
      If posSalto > 0 Then
        Begin
          linea := Copy(temp, 1, posSalto - 1);
          Delete(temp, 1, posSalto + 1);
        End
      Else
        Begin
          linea := temp;
          temp := '';
        End;
      If Length(linea) > 0 Then
        Begin
          Inc(cant);
          lineas[cant] := linea;
          ObtenerDatos(linea, lista[cant]);
        End;
    End;
End;

Function PeliculaYaMostrada(mostradas: String; peli: TPelicula): Boolean;
Var clave: String;
Begin
  ClavePelicula(peli, clave);
  PeliculaYaMostrada := Pos(clave, mostradas) > 0;
End;

Procedure ClavePelicula(peli: TPelicula; Var clave: String);
Begin
  clave := peli.titulo + '|' + peli.anio;
End;

Procedure AgregarPeliculaMostrada(Var mostradas: String; peli: TPelicula);
Var clave: String;
Begin
  ClavePelicula(peli, clave);
  If Length(mostradas) > 0 Then
    mostradas := mostradas + '§' + clave
  Else
    mostradas := clave;
End;

Procedure CabeceraPelicula(peli: TPelicula; indice: Integer; Var bloque: String);
Var num: String;
Begin
  If indice > 0 Then
    num := IntToStr(indice) + ') '
  Else
    num := '';
  bloque := '  ' + num + peli.titulo + '  (' + peli.anio + ')' + #13#10;
  bloque := bloque + '    Genero: ' + peli.genero + #13#10;
  bloque := bloque + '    Director: ' + peli.director + #13#10;
  bloque := bloque + '    Actores: ' + peli.actor + #13#10;
  If peli.franquicia <> '-' Then
    bloque := bloque + '    Franquicia: ' + peli.franquicia + #13#10;
  bloque := bloque + '    Ingresos: ' + IntToStr(peli.ingresos) +
            ' M USD   Vistas: ' + IntToStr(peli.vistas) + ' M';
End;

Procedure FormatearUna(peli: TPelicula; Var salida: String);
Var bloque, lineaRayas: String;
Begin
  lineaRayas := '------------------------------------------';
  CabeceraPelicula(peli, 0, bloque);
  salida := lineaRayas + #13#10 + bloque + #13#10 + lineaRayas;
End;

Procedure FormatearLista(pelis: String; Var salida: String);
Var
  lista: TListaPelis;
  lineas: TLineaPelis;
  cant, i: Integer;
  bloque: String;
  lineaRayas: String;
Begin
  salida := '';
  lineaRayas := '------------------------------------------';
  SepararLista(pelis, lista, lineas, cant);
  For i := 1 To cant Do
    Begin
      CabeceraPelicula(lista[i], i, bloque);
      salida := salida + lineaRayas + #13#10 + bloque + #13#10;
    End;
End;

End.