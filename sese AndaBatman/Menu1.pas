Unit menu1;
{$H+}

{ ================================================================ }
{  Menu.pas - Flujo conversacional del chatbot                     }
{  Todo el estado vive en variables locales de menu_principal y de }
{  los procedimientos auxiliares. Sin break/exit/halt.             }
{ ================================================================ }

Interface

Uses crt, validadores, chat, archivo, informacion, iniciar_archivo, sysutils;

Procedure menu_principal;

Implementation

{ ---------------------------------------------------------------- }
{  Muestra una lista de peliculas. Si soloNoVistas es True, filtra }
{  las ya vistas y las marca. Si no, muestra todas y las marca.    }
{ ---------------------------------------------------------------- }
Procedure MostrarLista(pelis: String; soloNoVistas: Boolean;
                       Var mostradas: String; Var mostreAlguna: Boolean);
Var
  lista: TListaPelis;
  lineas: TLineaPelis;
  cant, i: Integer;
  noVistas, salida: String;
Begin
  mostreAlguna := False;
  SepararLista(pelis, lista, lineas, cant);
  If cant > 0 Then
    Begin
      If soloNoVistas Then
        Begin
          noVistas := '';
          For i := 1 To cant Do
            If Not PeliculaYaMostrada(mostradas, lista[i]) Then
              Begin
                AgregarPeliculaMostrada(mostradas, lista[i]);
                noVistas := noVistas + lineas[i] + #13#10;
              End;
          If Length(noVistas) > 0 Then
            Begin
              mostreAlguna := True;
              FormatearLista(noVistas, salida);
              WriteLn(salida);
            End
          Else
            NoEncontreMas;
        End
      Else
        Begin
          For i := 1 To cant Do
            AgregarPeliculaMostrada(mostradas, lista[i]);
          mostreAlguna := True;
          FormatearLista(pelis, salida);
          WriteLn(salida);
        End;
    End;
End;

{ ---------------------------------------------------------------- }
{  Marca como vistas las peliculas elegidas en la respuesta        }
{  del usuario ("1,3", "todas" o "ninguna").                       }
{ ---------------------------------------------------------------- }
Procedure MarcarVistos(respuesta: String; cand: TListaPelis;
                       candCant: Integer; Var mostradas: String;
                       Var seleccionadas: array of Boolean);
Var
  resto, token: String;
  num: LongInt;
  codigo: Integer;
  i, posComa: Integer;
Begin
  For i := 0 To Length(seleccionadas) - 1 Do
    seleccionadas[i] := False;
  If Pos('todas', respuesta) > 0 Then
    Begin
      For i := 1 To candCant Do
        Begin
          seleccionadas[i - 1] := True;
          AgregarPeliculaMostrada(mostradas, cand[i]);
        End;
    End
  Else If Pos('ninguna', respuesta) = 0 Then
    Begin
      resto := respuesta;
      While (Length(resto) > 0) Do
        Begin
          posComa := Pos(',', resto);
          If posComa > 0 Then
            Begin
              token := Trim(Copy(resto, 1, posComa - 1));
              Delete(resto, 1, posComa);
            End
          Else
            Begin
              token := Trim(resto);
              resto := '';
            End;

          If Length(token) > 0 Then
            Begin
              Val(token, num, codigo);
              If (codigo = 0) And (num >= 1) And (num <= candCant) Then
                Begin
                  seleccionadas[num - 1] := True;
                  AgregarPeliculaMostrada(mostradas, cand[num]);
                End;
            End;
        End;
    End;
End;

{ ---------------------------------------------------------------- }
{  Procesa las preguntas de informacion general.                   }
{ ---------------------------------------------------------------- }
Procedure ProcesarInformacion(Var f: TextFile; respuesta: String);
Var
  nombre, gen, salida: String;
  cantidad: Integer;
  total: LongInt;
  totalAct: Integer;
  enc: Boolean;
  peli: TPelicula;
Begin
  textcolor(Cyan);
  RespuestaInfo;

  If ContieneInfoCuantasDirector(respuesta) Then
    Begin
      ExtraerDirector(respuesta, nombre);
      If Length(nombre) > 0 Then
        Begin
          ContarDirector(f, nombre, cantidad);
          textcolor(Green);
          If cantidad > 0 Then
            WriteLn('El/la director/a ', nombre, ' tiene ', cantidad,
                    ' pelicula/s en la base.')
          Else
            WriteLn('No tengo registrado nada de ', nombre, '.');
        End
      Else
        IngresoErroneo;
    End
  Else If ContieneInfoCuantasActor(respuesta) Then
         Begin
           ExtraerActor(respuesta, nombre);
           If Length(nombre) > 0 Then
             Begin
               ContarActor(f, nombre, cantidad);
               textcolor(Green);
               If cantidad > 0 Then
                 WriteLn('La/el actor/actriz ', nombre, ' participa en ',
                         cantidad, ' pelicula/s de la base.')
               Else
                 WriteLn('No tengo registrado nada de ', nombre, '.');
             End
           Else
             IngresoErroneo;
         End
  Else If ContieneInfoMasDirector(respuesta) Then
         Begin
           DirectorMasPeliculas(f, nombre, cantidad);
           textcolor(Green);
           WriteLn('El director con mas peliculas registradas es ', nombre,
                   ' con ', cantidad, '.');
         End
  Else If ContieneInfoMasActor(respuesta) Then
         Begin
           ActorMasPeliculas(f, nombre, cantidad);
           textcolor(Green);
           WriteLn('El actor con mas peliculas registradas es ', nombre,
                   ' con ', cantidad, '.');
         End
  Else If ContieneInfoMasRepetido(respuesta) Then
         Begin
           DirectorMasPeliculas(f, nombre, cantidad);
           textcolor(Green);
           WriteLn('El que mas aparece como director es ', nombre,
                   ' con ', cantidad, ' peliculas.');
ActorMasPeliculas(f, gen, totalAct);
            WriteLn('Y como actor, el que mas aparece es ', gen,
                    ' con ', totalAct, ' participaciones.');
         End
  Else If ContieneInfoMasVista(respuesta) Then
         Begin
           PeliculaMasVista(f, peli, enc);
           If enc Then
             Begin
               textcolor(Blue);
               FormatearUna(peli, salida);
               WriteLn(salida);
               textcolor(Green);
               WriteLn('La mas vista de la base, con ', peli.vistas,
                       ' M de espectadores.');
             End
           Else
             RespNegativa;
         End
  Else If ContieneInfoMasIngresos(respuesta) Then
         Begin
           If (Pos('genero', respuesta) > 0) Or (ContieneGenero(respuesta)) Then
             Begin
               GeneroMasIngresos(f, gen, total);
               textcolor(Green);
               WriteLn('El genero que mas ingreso genera sumando toda la base es ',
                       gen, ' con ', total, ' M USD.');
             End
           Else
             Begin
               PeliculaMasIngresos(f, peli, enc);
               If enc Then
                 Begin
                   textcolor(Blue);
                   FormatearUna(peli, salida);
                   WriteLn(salida);
                   textcolor(Green);
                   WriteLn('La que mas recaudo es ', peli.titulo, ' con ',
                           peli.ingresos, ' M USD.');
                 End
               Else
                 RespNegativa;
             End;
         End
  Else
    Begin
      TotalPeliculas(f, cantidad);
      textcolor(Green);
      WriteLn('Tengo ', cantidad, ' peliculas en la base. Preguntame por ejemplo:');
      WriteLn('"cuantas peliculas dirigio nolan?", "quien se repite mas?" o "cual fue la mas vista?".');
    End;

  textcolor(White);
End;

{ ---------------------------------------------------------------- }
{  Bucle principal con estados: azar, "cual viste" y busqueda.     }
{ ---------------------------------------------------------------- }
Procedure menu_principal;
Var
  f: TextFile;
  res, respuesta, salidaPelis, pelis, gen, anio, epoca, direc, actor,
  franq, frag, noVistas: String;
  peliAzar: TPelicula;
  mostradas: String;
  modoAzar, preguntandoViste, salir, enc: Boolean;
  pasoAzar, desde, hasta, cant, i: Integer;
  azarGen, azarEp: String;
  cand: TListaPelis;
  candLineas: TLineaPelis;
  candCant: Integer;
  vistasSeleccionadas: array[0..MAXCAND - 1] of Boolean;
  totalSaga: LongInt;
Begin
  iniciarArchivo(f);
  clrscr;
  textcolor(Green);
  SaludosInicio;

  mostradas := '';
  modoAzar := False;
  preguntandoViste := False;
  pasoAzar := 0;
  salir := False;

  While (Not salir) Do
    Begin
      textcolor(White);
      Write('> ');
      ReadLn(res);
      respuesta := lowercase(Trim(res));

      If ContienSalir(respuesta) Then
        salir := True
      Else If modoAzar Then
             Begin
               If pasoAzar = 0 Then
                 Begin
                   BuscarGenero(respuesta, azarGen);
                   textcolor(Green);
                   PreguntaEpocaAzar;
                   pasoAzar := 1;
                 End
               Else If pasoAzar = 1 Then
                      Begin
                        azarEp := '';
                        If Not EsDaIgual(respuesta) Then
                          ExtraerEpoca(respuesta, azarEp);
                        RangoEpoca(azarEp, desde, hasta);
                        enc := False;
                        PeliculaAlAzar(f, azarGen, azarEp, desde, hasta,
                                       mostradas, peliAzar, enc);
                        If enc Then
                          Begin
                            textcolor(Green);
                            RespPositiva;
                            WriteLn;
                            textcolor(Blue);
                            FormatearUna(peliAzar, salidaPelis);
                            WriteLn(salidaPelis);
                            textcolor(Green);
                            PreguntaGustoAzar;
                            pasoAzar := 2;
                          End
                        Else
                          Begin
                            RespNegativa;
                            TextoAzarAgotado;
                            modoAzar := False;
                            pasoAzar := 0;
                          End;
                      End
               Else If pasoAzar = 2 Then
                      Begin
                        If (Pos('otra', respuesta) > 0) Or
                           (Pos('otro', respuesta) > 0) Then
                          Begin
                            enc := False;
                            PeliculaAlAzar(f, azarGen, azarEp, desde, hasta,
                                           mostradas, peliAzar, enc);
                            If enc Then
                              Begin
                                textcolor(Green);
                                RespPositiva;
                                WriteLn;
                                textcolor(Blue);
                                FormatearUna(peliAzar, salidaPelis);
                                WriteLn(salidaPelis);
                                textcolor(Green);
                                PreguntaGustoAzar;
                              End
                            Else
                              Begin
                                RespNegativa;
                                TextoAzarAgotado;
                                modoAzar := False;
                                pasoAzar := 0;
                              End;
                          End
                        Else
                          Begin
                            AgregarPeliculaMostrada(mostradas, peliAzar);
                            textcolor(Green);
                            WriteLn('Dale, esa queda para vos! Pedime otra cuando quieras.');
                            modoAzar := False;
                            pasoAzar := 0;
                          End;
                      End;
             End
      Else If preguntandoViste Then
             Begin
               textcolor(Green);
               MarcarVistos(respuesta, cand, candCant, mostradas,
                            vistasSeleccionadas);
               noVistas := '';
               For i := 1 To candCant Do
                 If Not vistasSeleccionadas[i - 1] Then
                   noVistas := noVistas + candLineas[i] + #13#10;
               If Length(noVistas) > 0 Then
                 Begin
                   WriteLn('Estas son las que te faltan por ver:');
                   textcolor(Blue);
                   FormatearLista(noVistas, salidaPelis);
                   WriteLn(salidaPelis);
                   For i := 1 To candCant Do
                     If Not vistasSeleccionadas[i - 1] Then
                       AgregarPeliculaMostrada(mostradas, cand[i]);
                 End
               Else
                 WriteLn('Las viste todas! Si queres te busco parecidas por genero.');
               textcolor(Green);
               preguntandoViste := False;
             End
      Else
        Begin
          If ContieneSaludo(respuesta) Then
            Begin
              textcolor(Green);
              RespuestaSaludo;
            End
          Else If ContieneInfoGeneral(respuesta) Then
                 ProcesarInformacion(f, respuesta)
          Else If ContieneAnio(respuesta) Then
                 Begin
                   ExtraerAnio(respuesta, anio);
                   textcolor(Green);
                   WriteLn('Buscando peliculas del anio ', anio, '...');
                   BuscarPorAnio(f, anio, pelis, cant);
                   If cant > 0 Then
                     Begin
                       textcolor(Blue);
                       MostrarLista(pelis, True, mostradas, enc);
                     End
                   Else
                     Begin
                       textcolor(Green);
                       WriteLn('No encontre peliculas del anio ', anio,
                               '. Proba con otro anio o una decada.');
                     End;
                   textcolor(Green);
                 End
          Else If ContieneEpoca(respuesta) Then
                 Begin
                   ExtraerEpoca(respuesta, epoca);
                   RangoEpoca(epoca, desde, hasta);
                   textcolor(Green);
                   WriteLn('Te busco cosas entre ', desde, ' y ', hasta, '...');
                   BuscarPorRangoAnios(f, desde, hasta, pelis, cant);
                   If cant > 0 Then
                     Begin
                       textcolor(Blue);
                       MostrarLista(pelis, True, mostradas, enc);
                     End
                   Else
                     RespNegativa;
                   textcolor(Green);
                 End
          Else If ContieneAlAzar(respuesta) Then
                 Begin
                   textcolor(Green);
                   BuscarGenero(respuesta, azarGen);
                   If azarGen = '' Then
                     Begin
                       PreguntaGeneroAzar;
                       pasoAzar := 0;
                     End
                   Else
                     Begin
                       WriteLn('(Anotado: ', azarGen, ')');
                       PreguntaEpocaAzar;
                       pasoAzar := 1;
                     End;
                   modoAzar := True;
                 End
          Else If ContieneMeGusta(respuesta) Or ContieneParecida(respuesta) Then
                 Begin
                   textcolor(Green);
                   ExtraerParecida(respuesta, frag);
                   If Length(frag) > 0 Then
                     Begin
                       BuscarParecidas(f, frag, pelis, cant);
                       If cant > 0 Then
                         Begin
                           WriteLn('Me gusta tu gusto! Te muestro las parecidas que tengo:');
                           textcolor(Blue);
                           FormatearLista(pelis, salidaPelis);
                           WriteLn(salidaPelis);
                           textcolor(Green);
                           PreguntaViste;
                           SepararLista(pelis, cand, candLineas, candCant);
                           For i := 0 To MAXCAND - 1 Do
                             vistasSeleccionadas[i] := False;
                           preguntandoViste := True;
                         End
                       Else
                         RespNegativa;
                     End
                   Else
                     RespNegativa;
                   textcolor(Green);
                 End
          Else If ContieneFranquicia(respuesta) Then
                 Begin
                   ExtraerFranquicia(respuesta, franq);
                   textcolor(Green);
                   WriteLn('Te busco la saga ', franq, '...');
                   BuscarPorFranquicia(f, franq, pelis, cant);
                   If cant > 0 Then
                     Begin
                       WriteLn('Tengo ', cant, ' registradas:');
                       textcolor(Blue);
                       MostrarLista(pelis, False, mostradas, enc);
                       textcolor(Green);
                       TotalFranquicia(f, franq, totalSaga);
                       AvisoSagaIncompleta(franq, cant, totalSaga);
                     End
                   Else
                     RespNegativa;
                   textcolor(Green);
                 End
          Else If (Pos('otra', respuesta) > 0) Or (Pos('otro', respuesta) > 0) Or
                  (Pos('siguiente', respuesta) > 0) Then
                 Begin
                   enc := False;
                   PeliculaAlAzar(f, '', '', 1950, 2026, mostradas, peliAzar, enc);
                   If enc Then
                     Begin
                       textcolor(Green);
                       RespPositiva;
                       WriteLn;
                       textcolor(Blue);
                       FormatearUna(peliAzar, salidaPelis);
                       WriteLn(salidaPelis);
                       AgregarPeliculaMostrada(mostradas, peliAzar);
                     End
                   Else
                     Begin
                       textcolor(Green);
                       RespNegativa;
                       WriteLn('A esta altura te las mostre casi todas. Cambiemos de tema.');
                     End;
                   textcolor(Green);
                 End
          Else If ContieneDirector(respuesta) Then
                 Begin
                   textcolor(Green);
                   ExtraerDirector(respuesta, direc);
                   If Length(direc) > 0 Then
                     Begin
                       WriteLn('Te busco todo de ', direc, '...');
                       BuscarPorDirector(f, direc, pelis, cant);
                       If cant > 0 Then
                         Begin
                           textcolor(Blue);
                           MostrarLista(pelis, True, mostradas, enc);
                         End
                       Else
                         RespNegativa;
                     End
                   Else
                     IngresoErroneo;
                   textcolor(Green);
                 End
          Else If ContieneActor(respuesta) Then
                 Begin
                   textcolor(Green);
                   ExtraerActor(respuesta, actor);
                   If Length(actor) > 0 Then
                     Begin
                       WriteLn('Te busco todo lo de ', actor, '...');
                       BuscarPorActor(f, actor, pelis, cant);
                       If cant > 0 Then
                         Begin
                           textcolor(Blue);
                           MostrarLista(pelis, True, mostradas, enc);
                         End
                       Else
                         RespNegativa;
                     End
                   Else
                     IngresoErroneo;
                   textcolor(Green);
                 End
          Else If ContieneGenero(respuesta) Then
                 Begin
                   BuscarGenero(respuesta, gen);
                   textcolor(Green);
                   WriteLn('Buscando pelis de ', gen, '...');
                   BuscarPorGenero(f, gen, pelis, cant);
                   If cant > 0 Then
                     Begin
                       textcolor(Blue);
                       MostrarLista(pelis, True, mostradas, enc);
                     End
                   Else
                     RespNegativa;
                   textcolor(Green);
                 End
          Else If Length(respuesta) >= 4 Then
                 Begin
                   BuscarParecidas(f, respuesta, pelis, cant);
                   If cant > 0 Then
                     Begin
                       textcolor(Green);
                       WriteLn('Ahi va, capaz te suena alguna de estas:');
                       textcolor(Blue);
                       MostrarLista(pelis, True, mostradas, enc);
                     End
                   Else
                     Begin
                       textcolor(Green);
                       RespNegativa;
                       WriteLn('Proba preguntar por genero, saga, actor o "al azar".');
                     End;
                   textcolor(Green);
End
           Else
             IngresoErroneo;
         End;
     End;

  textcolor(Green);
  SaludosDespedida;
  cerrarArchivo(f);
End;

End.