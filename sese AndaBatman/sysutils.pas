
Unit sysutils;
{$unitpath ../dos, ../crt}

Interface

Type 
  TDateTime = Double;

Function Now: TDateTime;
Function GetTickCount: LongInt;
Function Trunc(X: TDateTime): LongInt;
Function DayOfWeek(DateTime: TDateTime): word;
Procedure DecodeDate(DateTime: TDateTime; Var Year, Month, Day: word);
Procedure DecodeTime(DateTime: TDateTime; Var Hour, Minute, Second, MilliSecond:
                     word);
Procedure Sleep(Milliseconds: LongInt);

Function IntToStr(Value: LongInt): string;
Function StrToInt(S: String): LongInt;
Function UpperCase(S: String): string;
Function LowerCase(S: String): string;
Function Trim(S: String): string;

Implementation

Uses 
dos, crt;

Function Now: TDateTime;

Var 
  year, month, day, dow: word;
  hour, minute, second, sec100: word;
Begin
  GetDate(year, month, day, dow);
  GetTime(hour, minute, second, sec100);
  Now := (hour / 24.0) + (minute / 1440.0) + (second / 86400.0);
  // Tiempo actual como fracción del día
  Now := Now + day + (month * 30.44) + (year * 365.25);
  // Años y meses en días (aproximado)
End;

Function Trunc(X: TDateTime): LongInt;
Begin
  Trunc := Round(X);
  // Simple implementación que redondea al entero más cercano
End;

Function DayOfWeek(DateTime: TDateTime): word;
Var 
  totalDays: LongInt;
Begin
  totalDays := Trunc(DateTime);
  // Algoritmo simple: día de la semana basado en días totales
  // 1 = domingo, 2 = lunes, ..., 7 = sábado
  DayOfWeek := (totalDays Mod 7) + 1;
End;

Procedure DecodeDate(DateTime: TDateTime; Var Year, Month, Day: word);

Var 
  totalDays: LongInt;
Begin
  totalDays := Trunc(DateTime);
  Year := totalDays Div 365;
  Month := (totalDays Mod 365) Div 30 + 1;
  Day := totalDays Mod 30 + 1;
End;

Procedure DecodeTime(DateTime: TDateTime; Var Hour, Minute, Second, MilliSecond:
                     word);

Var 
  fracDay: TDateTime;
Begin
  fracDay := DateTime - Trunc(DateTime);
  Hour := Trunc(fracDay * 24);
  Minute := Trunc((fracDay * 24 - Hour) * 60);
  Second := Trunc(((fracDay * 24 - Hour) * 60 - Minute) * 60);
  MilliSecond := Trunc(((((fracDay * 24 - Hour) * 60 - Minute) * 60) - Second) *
                 1000);
End;

Function GetTickCount: LongInt;

Var 
  hour, minute, second, sec100: word;
Begin
  GetTime(hour, minute, second, sec100);
  GetTickCount := (hour * 3600000) + (minute * 60000) + (second * 1000) + (sec100 * 10);
End;

Procedure Sleep(Milliseconds: LongInt);

Var 
  start: LongInt;
Begin
  start := GetTickCount;
  While (GetTickCount - start < Milliseconds) Do;
End;

Function IntToStr(Value: LongInt): string;

Var 
  res: string;
Begin
  Str(Value, res);
  IntToStr := res;
End;

Function StrToInt(S: String): LongInt;

Var 
  Value: LongInt;
  Code: Integer;
Begin
  Val(S, Value, Code);
  If Code = 0 Then
    StrToInt := Value
  Else
    StrToInt := 0;
  // Devolver 0 en caso de error (puedes manejar esto de otra forma)
End;

Function UpperCase(S: String): string;

Var 
  i: integer;
  resultStr: string;
Begin
  resultStr := S;
  For i := 1 To length(resultStr) Do
    If (resultStr[i] >= 'a') And (resultStr[i] <= 'z') Then
      resultStr[i] := chr(ord(resultStr[i]) - 32);
  UpperCase := resultStr;
End;

Function LowerCase(S: String): string;

Var 
  i: integer;
  resultStr: string;
Begin
  resultStr := S;
  For i := 1 To length(resultStr) Do
    If (resultStr[i] >= 'A') And (resultStr[i] <= 'Z') Then
      resultStr[i] := chr(ord(resultStr[i]) + 32);
  LowerCase := resultStr;
End;

Function Trim(S: String): string;

Var 
  i: integer;
  resultStr: string;
Begin
  resultStr := S;
  
  // Eliminar espacios en blanco del inicio
  While (length(resultStr) > 0) And (resultStr[1] = ' ') Do
    delete(resultStr, 1, 1);

  // Eliminar espacios en blanco del final
  i := length(resultStr);
  While (i > 0) And (resultStr[i] = ' ') Do
    Begin
      delete(resultStr, i, 1);
      i := length(resultStr);
    End;

  Trim := resultStr;
End;

End.
