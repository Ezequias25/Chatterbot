Unit validadores;
{$H+}

{ ================================================================ }
{  Validadores.pas - Deteccion de intencion                        }
{  Cada accion del chatbot tiene su validador.                     }
{  Sin break, sin exit, sin halt: se corta con banderas booleanas. }
{ ================================================================ }

Interface

Uses sysutils, palabras_claves;

Function ContienSalir(cadena: String): Boolean;
Function ContieneSaludo(cadena: String): Boolean;

Function ContieneGenero(cadena: String): Boolean;
Procedure BuscarGenero(cadena: String; Var gen: String);

Function ContieneDirector(cadena: String): Boolean;
Procedure ExtraerDirector(cadena: String; Var nom: String);

Function ContieneActor(cadena: String): Boolean;
Procedure ExtraerActor(cadena: String; Var nom: String);

Function ContieneAnio(cadena: String): Boolean;
Procedure ExtraerAnio(cadena: String; Var anio: String);

Function ContieneEpoca(cadena: String): Boolean;
Procedure ExtraerEpoca(cadena: String; Var ep: String);
Procedure RangoEpoca(ep: String; Var desde, hasta: Integer);

Function ContieneFranquicia(cadena: String): Boolean;
Procedure ExtraerFranquicia(cadena: String; Var franq: String);

Function ContieneAlAzar(cadena: String): Boolean;
Function ContieneMeGusta(cadena: String): Boolean;
Function ContieneParecida(cadena: String): Boolean;
Procedure ExtraerParecida(cadena: String; Var frag: String);
Procedure LimpiarFragmento(Var frag: String);

Function ContieneInfoGeneral(cadena: String): Boolean;
Function ContieneInfoCuantasDirector(cadena: String): Boolean;
Function ContieneInfoCuantasActor(cadena: String): Boolean;
Function ContieneInfoMasVista(cadena: String): Boolean;
Function ContieneInfoMasIngresos(cadena: String): Boolean;
Function ContieneInfoMasRepetido(cadena: String): Boolean;
Function ContieneInfoMasDirector(cadena: String): Boolean;
Function ContieneInfoMasActor(cadena: String): Boolean;

Function EsDaIgual(cadena: String): Boolean;

Implementation

Function ContienSalir(cadena: String): Boolean;
Var i: Integer;
Begin
  ContienSalir := False;
  i := 1;
  While (i <= CANT_DESPEDIDAS) And (Not ContienSalir) Do
    Begin
      If Pos(despedida[i], cadena) > 0 Then
        ContienSalir := True;
      Inc(i);
    End;
End;

Function ContieneSaludo(cadena: String): Boolean;
Var i: Integer;
Begin
  ContieneSaludo := False;
  i := 1;
  While (i <= CANT_SALUDOS) And (Not ContieneSaludo) Do
    Begin
      If Pos(saludo[i], cadena) > 0 Then
        ContieneSaludo := True;
      Inc(i);
    End;
End;

Function ContieneGenero(cadena: String): Boolean;
Var i: Integer;
Begin
  ContieneGenero := False;
  i := 1;
  While (i <= CANT_GENEROS) And (Not ContieneGenero) Do
    Begin
      If Pos(genero[i], cadena) > 0 Then
        ContieneGenero := True;
      Inc(i);
    End;
End;

Procedure BuscarGenero(cadena: String; Var gen: String);
Var i: Integer;
Begin
  gen := '';
  i := 1;
  While (i <= CANT_GENEROS) And (gen = '') Do
    Begin
      If Pos(genero[i], cadena) > 0 Then
        gen := genero[i];
      Inc(i);
    End;
End;

{ Devuelve la posicion del trigger que aparece mas tarde en la frase.
  Para director y actor se escribe por separado para no usar arreglos
  abiertos (compatibilidad Turbo Pascal). }
Function PosUltimoDirector(texto: String): Integer;
Var i, posTemp: Integer;
Begin
  PosUltimoDirector := 0;
  For i := 1 To CANT_DIRECTOR_TRIGGERS Do
    Begin
      posTemp := Pos(directores[i], texto);
      If posTemp > 0 Then
        If posTemp > PosUltimoDirector Then
          PosUltimoDirector := posTemp;
    End;
End;

Function PosUltimoActor(texto: String): Integer;
Var i, posTemp: Integer;
Begin
  PosUltimoActor := 0;
  For i := 1 To CANT_ACTOR_TRIGGERS Do
    Begin
      posTemp := Pos(actores[i], texto);
      If posTemp > 0 Then
        If posTemp > PosUltimoActor Then
          PosUltimoActor := posTemp;
    End;
End;

Function ContieneDirector(cadena: String): Boolean;
Begin
  ContieneDirector := PosUltimoDirector(cadena) > 0;
End;

Procedure QuitarPalabraAntes(Var s: String);
Begin
  s := Trim(s);
  If Copy(s, 1, 4) = 'por ' Then
    Delete(s, 1, 4)
  Else If Copy(s, 1, 3) = 'de ' Then
         Delete(s, 1, 3);
  s := Trim(s);
End;

Procedure ExtraerDirector(cadena: String; Var nom: String);
Var i, posMejor, posTemp, lon: Integer;
    temp: String;
Begin
  nom := '';
  posMejor := 0;
  For i := 1 To CANT_DIRECTOR_TRIGGERS Do
    Begin
      posTemp := Pos(directores[i], cadena);
      If posTemp > 0 Then
        If posTemp > posMejor Then
          Begin
            posMejor := posTemp;
            lon := Length(directores[i]);
            temp := Copy(cadena, posTemp + lon, Length(cadena));
          End;
    End;
  If posMejor > 0 Then
    Begin
      QuitarPalabraAntes(temp);
      nom := temp;
    End;
End;

Function ContieneActor(cadena: String): Boolean;
Begin
  ContieneActor := PosUltimoActor(cadena) > 0;
End;

Procedure ExtraerActor(cadena: String; Var nom: String);
Var i, posMejor, posTemp, lon: Integer;
    temp: String;
Begin
  nom := '';
  posMejor := PosUltimoActor(cadena);
  If posMejor = 0 Then
    Begin
      { "peliculas de tom hanks" sin verbo actor }
      posTemp := Pos('peliculas de', cadena);
      If posTemp = 0 Then
        posTemp := Pos('pelicula de', cadena);
      If posTemp > 0 Then
        Begin
          temp := Copy(cadena, posTemp + Length('pelicula de'), Length(cadena));
          QuitarPalabraAntes(temp);
          nom := temp;
        End;
    End
  Else
    Begin
      i := 1;
      While (i <= CANT_ACTOR_TRIGGERS) And (posMejor > 0) Do
        Begin
          posTemp := Pos(actores[i], cadena);
          If posTemp = posMejor Then
            Begin
              lon := Length(actores[i]);
              temp := Copy(cadena, posTemp + lon, Length(cadena));
              posMejor := 0;
            End;
          Inc(i);
        End;
      If Length(temp) > 0 Then
        Begin
          QuitarPalabraAntes(temp);
          nom := temp;
        End;
    End;
End;

Function ContieneAnio(cadena: String): Boolean;
Var i: Integer;
    anioStr: String;
    num: LongInt;
Begin
  ContieneAnio := False;
  i := 1;
  While (i <= Length(cadena) - 3) And (Not ContieneAnio) Do
    Begin
      If (cadena[i] >= '0') And (cadena[i] <= '9') And
         (cadena[i + 1] >= '0') And (cadena[i + 1] <= '9') And
         (cadena[i + 2] >= '0') And (cadena[i + 2] <= '9') And
         (cadena[i + 3] >= '0') And (cadena[i + 3] <= '9') Then
        Begin
          anioStr := Copy(cadena, i, 4);
          num := StrToInt(anioStr);
          If (num >= 1900) And (num <= 2030) Then
            ContieneAnio := True;
        End;
      Inc(i);
    End;
End;

Procedure ExtraerAnio(cadena: String; Var anio: String);
Var i: Integer;
    anioStr: String;
    num: LongInt;
Begin
  anio := '';
  i := 1;
  While (i <= Length(cadena) - 3) And (anio = '') Do
    Begin
      If (cadena[i] >= '0') And (cadena[i] <= '9') And
         (cadena[i + 1] >= '0') And (cadena[i + 1] <= '9') And
         (cadena[i + 2] >= '0') And (cadena[i + 2] <= '9') And
         (cadena[i + 3] >= '0') And (cadena[i + 3] <= '9') Then
        Begin
          anioStr := Copy(cadena, i, 4);
          num := StrToInt(anioStr);
          If (num >= 1900) And (num <= 2030) Then
            anio := anioStr;
        End;
      Inc(i);
    End;
End;

Function ContieneEpoca(cadena: String): Boolean;
Var i: Integer;
Begin
  ContieneEpoca := False;
  i := 1;
  While (i <= CANT_EPOCAS) And (Not ContieneEpoca) Do
    Begin
      If Pos(epoca[i], cadena) > 0 Then
        ContieneEpoca := True;
      Inc(i);
    End;
End;

Procedure ExtraerEpoca(cadena: String; Var ep: String);
Var i: Integer;
Begin
  ep := '';
  i := 1;
  While (i <= CANT_EPOCAS) And (ep = '') Do
    Begin
      If Pos(epoca[i], cadena) > 0 Then
        ep := epoca[i];
      Inc(i);
    End;
End;

Procedure RangoEpoca(ep: String; Var desde, hasta: Integer);
Begin
  desde := 1950;
  hasta := 2026;
  If (Pos('60', ep) > 0) Or (Pos('sesenta', ep) > 0) Then
    Begin
      desde := 1960;
      hasta := 1969;
    End
  Else If (Pos('70', ep) > 0) Or (Pos('setenta', ep) > 0) Then
         Begin
           desde := 1970;
           hasta := 1979;
         End
  Else If (Pos('80', ep) > 0) Or (Pos('ochenta', ep) > 0) Then
         Begin
           desde := 1980;
           hasta := 1989;
         End
  Else If (Pos('90', ep) > 0) Or (Pos('noventa', ep) > 0) Then
         Begin
           desde := 1990;
           hasta := 1999;
         End
  Else If (Pos('50', ep) > 0) Or (Pos('cincuenta', ep) > 0) Then
         Begin
           desde := 1950;
           hasta := 1959;
         End
  Else If (Pos('clasicos', ep) > 0) Or (Pos('clasicas', ep) > 0) Or
          (Pos('antiguo', ep) > 0) Or (Pos('viejo', ep) > 0) Or
          (Pos('vieja', ep) > 0) Or (Pos('siglo 20', ep) > 0) Or
          (Pos('siglo xx', ep) > 0) Then
         Begin
           desde := 1950;
           hasta := 1990;
         End
  Else If (Pos('siglo 21', ep) > 0) Or (Pos('siglo xxi', ep) > 0) Or
          (Pos('milenio', ep) > 0) Or (Pos('moderno', ep) > 0) Or
          (Pos('actual', ep) > 0) Or (Pos('recientes', ep) > 0) Then
         Begin
           desde := 2000;
           hasta := 2026;
         End;
End;

Function ContieneFranquicia(cadena: String): Boolean;
Var i: Integer;
Begin
  ContieneFranquicia := False;
  i := 1;
  While (i <= CANT_FRANQUICIAS) And (Not ContieneFranquicia) Do
    Begin
      If Pos(franquicia[i], cadena) > 0 Then
        ContieneFranquicia := True;
      Inc(i);
    End;
End;

Procedure ExtraerFranquicia(cadena: String; Var franq: String);
Var i: Integer;
    posTemp, posMejor: Integer;
Begin
  franq := '';
  posMejor := 0;
  For i := 1 To CANT_FRANQUICIAS Do
    Begin
      posTemp := Pos(franquicia[i], cadena);
      If posTemp > 0 Then
        If posTemp > posMejor Then
          Begin
            posMejor := posTemp;
            franq := franquicia[i];
          End;
    End;
End;

Function ContieneAlAzar(cadena: String): Boolean;
Var i: Integer;
Begin
  ContieneAlAzar := False;
  i := 1;
  While (i <= CANT_AZAR_TRIGGERS) And (Not ContieneAlAzar) Do
    Begin
      If Pos(al_azar[i], cadena) > 0 Then
        ContieneAlAzar := True;
      Inc(i);
    End;
End;

Function ContieneMeGusta(cadena: String): Boolean;
Var i: Integer;
Begin
  ContieneMeGusta := False;
  i := 1;
  While (i <= CANT_ME_GUSTA_TRIGGERS) And (Not ContieneMeGusta) Do
    Begin
      If Pos(me_gusta[i], cadena) > 0 Then
        ContieneMeGusta := True;
      Inc(i);
    End;
End;

Function ContieneParecida(cadena: String): Boolean;
Var i: Integer;
Begin
  ContieneParecida := False;
  i := 1;
  While (i <= CANT_PARECIDA_TRIGGERS) And (Not ContieneParecida) Do
    Begin
      If Pos(parecida[i], cadena) > 0 Then
        ContieneParecida := True;
      Inc(i);
    End;
End;

Procedure LimpiarFragmento(Var frag: String);
Var i, posEsp, intentos: Integer;
    palabra, resto: String;
    cortado: Boolean;
Begin
  intentos := 0;
  cortado := True;
  While (Length(frag) > 0) And cortado And (intentos < 15) Do
    Begin
      cortado := False;
      frag := Trim(frag);
      posEsp := Pos(' ', frag);
      If posEsp = 0 Then
        Begin
          palabra := frag;
          resto := '';
        End
      Else
        Begin
          palabra := Copy(frag, 1, posEsp - 1);
          resto := Copy(frag, posEsp + 1, Length(frag));
        End;
      For i := 1 To CANT_STOPWORDS Do
        If palabra = stopwords[i] Then
          Begin
            cortado := True;
            frag := resto;
          End;
      Inc(intentos);
    End;
  frag := Trim(frag);
End;

Procedure ExtraerParecida(cadena: String; Var frag: String);
Var i, posTemp, posMejor, lon: Integer;
    temp: String;
Begin
  frag := '';
  posMejor := 0;
  For i := 1 To CANT_ME_GUSTA_TRIGGERS Do
    Begin
      posTemp := Pos(me_gusta[i], cadena);
      If posTemp > 0 Then
        If posTemp > posMejor Then
          Begin
            posMejor := posTemp;
            lon := Length(me_gusta[i]);
            temp := Copy(cadena, posTemp + lon, Length(cadena));
          End;
    End;
  If posMejor = 0 Then
    For i := 1 To CANT_PARECIDA_TRIGGERS Do
      Begin
        posTemp := Pos(parecida[i], cadena);
        If posTemp > 0 Then
          If posTemp > posMejor Then
            Begin
              posMejor := posTemp;
              lon := Length(parecida[i]);
              temp := Copy(cadena, posTemp + lon, Length(cadena));
            End;
      End;
  If posMejor = 0 Then
    For i := 1 To CANT_ETIQUETA_TRIGGERS Do
      Begin
        posTemp := Pos(etiqueta[i], cadena);
        If posTemp > 0 Then
          If posTemp > posMejor Then
            Begin
              posMejor := posTemp;
              lon := Length(etiqueta[i]);
              temp := Copy(cadena, posTemp + lon, Length(cadena));
            End;
      End;
  If posMejor > 0 Then
    Begin
      QuitarPalabraAntes(temp);
      LimpiarFragmento(temp);
      frag := temp;
    End;
End;

Function ContieneInfoGeneral(cadena: String): Boolean;
Begin
  ContieneInfoGeneral :=
    (Pos('informacion', cadena) > 0) Or (Pos('estadistica', cadena) > 0) Or
    (Pos('cuantas', cadena) > 0) Or (Pos('cuantos', cadena) > 0) Or
    (Pos('cuanta', cadena) > 0) Or (Pos('cuanto', cadena) > 0) Or
    (Pos('quien', cadena) > 0) Or (Pos('quienes', cadena) > 0) Or
    (Pos('mas vista', cadena) > 0) Or (Pos('mas vistas', cadena) > 0) Or
    (Pos('mas ingresos', cadena) > 0) Or (Pos('se repite', cadena) > 0) Or
    (Pos('repetido', cadena) > 0) Or (Pos('mas peliculas', cadena) > 0) Or
    (Pos('con mas', cadena) > 0) Or (Pos('recaudo', cadena) > 0);
End;

Function ContieneInfoCuantasDirector(cadena: String): Boolean;
Var hayCant, hayDir: Boolean;
Begin
  hayCant := (Pos('cuantas', cadena) > 0) Or (Pos('cuantos', cadena) > 0) Or
             (Pos('cuanto', cadena) > 0);
  hayDir := (Pos('dirigio', cadena) > 0) Or (Pos('dirigida', cadena) > 0) Or
            (Pos('dirigidas', cadena) > 0) Or (Pos('dirigido', cadena) > 0) Or
            (Pos('director', cadena) > 0);
  ContieneInfoCuantasDirector := hayCant And hayDir;
End;

Function ContieneInfoCuantasActor(cadena: String): Boolean;
Var hayCant, hayAct: Boolean;
Begin
  hayCant := (Pos('cuantas', cadena) > 0) Or (Pos('cuantos', cadena) > 0) Or
             (Pos('cuanto', cadena) > 0);
  hayAct := (Pos('actuo', cadena) > 0) Or (Pos('actua', cadena) > 0) Or
            (Pos('actuado', cadena) > 0) Or (Pos('protagonizo', cadena) > 0) Or
            (Pos('protagonizada', cadena) > 0);
  ContieneInfoCuantasActor := hayCant And hayAct;
End;

Function ContieneInfoMasVista(cadena: String): Boolean;
Begin
  ContieneInfoMasVista :=
    (Pos('mas vista', cadena) > 0) Or (Pos('mas vistas', cadena) > 0) Or
    (Pos('taquillera', cadena) > 0);
End;

Function ContieneInfoMasIngresos(cadena: String): Boolean;
Begin
  ContieneInfoMasIngresos :=
    (Pos('ingresos', cadena) > 0) Or (Pos('recaudo', cadena) > 0) Or
    (Pos('recaudacion', cadena) > 0) Or (Pos('genero mas', cadena) > 0);
End;

Function ContieneInfoMasRepetido(cadena: String): Boolean;
Begin
  ContieneInfoMasRepetido :=
    (Pos('se repite', cadena) > 0) Or (Pos('repetido', cadena) > 0) Or
    (Pos('repite', cadena) > 0) Or (Pos('mas veces', cadena) > 0) Or
    (Pos('quien tiene mas peliculas', cadena) > 0);
End;

Function ContieneInfoMasDirector(cadena: String): Boolean;
Begin
  ContieneInfoMasDirector :=
    (Pos('director', cadena) > 0) And
    ((Pos('con mas', cadena) > 0) Or (Pos('mas peliculas', cadena) > 0)) And
    (Pos('cuantas', cadena) = 0);
End;

Function ContieneInfoMasActor(cadena: String): Boolean;
Begin
  ContieneInfoMasActor :=
    ((Pos('actor', cadena) > 0) Or (Pos('actores', cadena) > 0)) And
    ((Pos('con mas', cadena) > 0) Or (Pos('mas peliculas', cadena) > 0)) And
    (Pos('cuantas', cadena) = 0);
End;

Function EsDaIgual(cadena: String): Boolean;
Begin
  EsDaIgual :=
    (Pos('da igual', cadena) > 0) Or (Pos('lo que sea', cadena) > 0) Or
    (Pos('cualquiera', cadena) > 0) Or (Pos('no se', cadena) > 0) Or
    (Pos('lo que venga', cadena) > 0) Or (Pos('vos elegi', cadena) > 0) Or
    (Pos('decidilo', cadena) > 0);
End;

End.