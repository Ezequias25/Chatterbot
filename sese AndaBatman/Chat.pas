Unit chat;
{$H+}

{ ================================================================ }
{  Chat.pas - Mensajes del chatbot (feedback no robotico)          }
{  Todo rioplatense, sin tildes, respuestas variadas al azar.      }
{ ================================================================ }

Interface

Uses sysutils, palabras_claves;

Procedure SaludosInicio;
Procedure SaludosDespedida;
Procedure RespPositiva;
Procedure RespNegativa;
Procedure IngresoErroneo;
Procedure RespuestaSaludo;

Procedure PreguntaGeneroAzar;
Procedure PreguntaEpocaAzar;
Procedure PreguntaGustoAzar;
Procedure PreguntaViste;
Procedure RespuestaInfo;
Procedure TextoAzarAgotado;

Procedure AvisoSagaIncompleta(franq: String; tenemos, total: LongInt);
Procedure NoEncontreMas;
Procedure SugerenciaSaga(saga: String);

Implementation

Const
  CANT_DESPEDIDA_RESP = 8;
  resp_despedida: array[1..8] Of String = (
                    'Hasta la proxima, que la fuerza te acompane.',
                    'Cuidate! Volve cuando quieras recomendaciones.',
                    'Nos vemos! Que el cine este con vos.',
                    'Bye! Pasa cuando tengas ganas de ver algo.',
                    'Chau! No te olvides: siempre hay una peli para vos.',
                    'Hasta luego! Buenas sesiones de cine.',
                    'Adios! Proba con algo al azar la proxima.',
                    'Nos vemos! Ya sabes donde aparecer para recomendar.');

Procedure SaludosInicio;
Begin
  WriteLn('========================================');
  WriteLn('|        CINECHAT - Grupo 11           |');
  WriteLn('|   Tu recomendador de peliculas       |');
  WriteLn('========================================');
  WriteLn;
  RespuestaSaludo;
  WriteLn('Podes buscar por genero, director, actor, anio o franquicia.');
  WriteLn('Ej: "dame una de sci-fi", "algo como batman" o "cual fue la mas vista?".');
End;

Procedure RespuestaSaludo;
Var i: Integer;
Begin
  i := Random(CANT_RESP_SALUDO) + 1;
  WriteLn(resp_saludo[i]);
End;

Procedure SaludosDespedida;
Var i: Integer;
Begin
  i := Random(CANT_DESPEDIDA_RESP) + 1;
  WriteLn(resp_despedida[i]);
End;

Procedure RespPositiva;
Var i: Integer;
Begin
  i := Random(CANT_RESP_POSITIVAS) + 1;
  WriteLn(resp_positivas[i]);
End;

Procedure RespNegativa;
Var i: Integer;
Begin
  i := Random(CANT_RESP_NEGATIVAS) + 1;
  WriteLn(resp_negativas[i]);
End;

Procedure IngresoErroneo;
Var i: Integer;
Begin
  i := Random(6) + 1;
  If i = 1 Then
    WriteLn('Che, no te entendi. Proba con un genero, una saga o "al azar".')
  Else If i = 2 Then
         WriteLn('Mmm, eso no lo proceso. Pedime algo como "accion" o "dirigida por nolan".')
  Else If i = 3 Then
         WriteLn('No cazo eso. Escribi algo tipo "dame una de terror" o "cual es la mas vista?".')
  Else If i = 4 Then
         WriteLn('Perdon, no tengo idea de que querias. Proba de nuevo.')
  Else If i = 5 Then
         WriteLn('No me suena eso. Decime un genero, actor, director o año.')
  Else
    WriteLn('Quede en blanco. Hablame de peliculas, por favor.');
End;

Procedure PreguntaGeneroAzar;
Begin
  WriteLn('Para recomendarte mejor, contame: que genero te tira hoy?');
  WriteLn('(accion, comedia, terror, romance, animacion... o "da igual")');
End;

Procedure PreguntaEpocaAzar;
Begin
  WriteLn('Listo. Y preferis algo clasico, de los 80/90 o actual?');
  WriteLn('(ej: "los 90", "recientes", "clasicas" o "da igual")');
End;

Procedure PreguntaGustoAzar;
Begin
  WriteLn('Te copa esta? Si queres otra decime "otra" o "dale" para confirmar.');
End;

Procedure PreguntaViste;
Begin
  WriteLn('De las que te mostre, cual ya viste?');
  WriteLn('Pone los numeros separados por coma (1,3) o "ninguna".');
End;

Procedure RespuestaInfo;
Var i: Integer;
Begin
  i := Random(CANT_RESPUESTAS_INFO) + 1;
  WriteLn(resp_info[i]);
End;

Procedure AvisoSagaIncompleta(franq: String; tenemos, total: LongInt);
Var saga: String;
    i: Integer;
Begin
  saga := franq;
  i := 1;
  While (i <= Length(saga)) Do
    Begin
      If saga[i] = '_' Then
        saga[i] := ' ';
      Inc(i);
    End;
  If total > 0 Then
    If total > tenemos Then
      Begin
        WriteLn('Te pasamos las ', tenemos, ' que tenemos de ', saga,
                ', pero la saga completa tiene ', total,
                ' en total. Nuestra base es chica: te animo a buscar las otras, seguro encontras alguna joyita.');
      End;
End;

Procedure NoEncontreMas;
Begin
  WriteLn('Ya te mostre todo lo que tengo de eso. Pedi otra cosa o algo al azar.');
End;

Procedure TextoAzarAgotado;
Begin
  WriteLn('Uy, no me queda ninguna que cumpla eso. Probemos de nuevo.');
End;

Procedure SugerenciaSaga(saga: String);
Begin
  WriteLn('Si queres, decime "me gusta ', saga,
          '" y busco parecidas para vos.');
End;

End.