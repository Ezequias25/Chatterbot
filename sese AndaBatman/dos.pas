
Unit dos;
{$unitpath ../sysutils}

Interface

Type 
  DateTime = Record
    year: word;
    month: word;
    day: word;
    hour: word;
    min: word;
    sec: word;
    hsec: word;
    // centisegundos (1/100 de segundo)
  End;

Procedure GetDate(Var year, month, day, dow: word);
Procedure GetTime(Var hour, min, sec, hsec: word);
Procedure GetDateTime(Var dt: DateTime);
Procedure Delay(ms: longint);

Implementation

Uses 
sysutils;

Procedure GetDate(Var year, month, day, dow: word);

Var 
  sysDate: TDateTime;
  y, m, d: word;
Begin
  sysDate := Now;
  DecodeDate(sysDate, y, m, d);
  year := y;
  month := m;
  day := d;
  dow := DayOfWeek(sysDate);
  // Día de la semana (1 = domingo, 7 = sábado)
End;

Procedure GetTime(Var hour, min, sec, hsec: word);

Var 
  sysTime: TDateTime;
  h, m, s, ms: word;
Begin
  sysTime := Now;
  DecodeTime(sysTime, h, m, s, ms);
  hour := h;
  min := m;
  sec := s;
  hsec := ms Div 10;
  // Pasamos milisegundos a centisegundos
End;

Procedure GetDateTime(Var dt: DateTime);

Var 
  sysDate: TDateTime;
  y, m, d: word;
  h, min, sec, ms: word;
Begin
  sysDate := Now;
  DecodeDate(sysDate, y, m, d);
  DecodeTime(sysDate, h, min, sec, ms);
  dt.year := y;
  dt.month := m;
  dt.day := d;
  dt.hour := h;
  dt.min := min;
  dt.sec := sec;
  dt.hsec := ms Div 10;
  // Convertimos milisegundos a centisegundos
End;

Procedure Delay(ms: longint);
Begin
  Sleep(ms);
  // Utilizamos la función Sleep de Pascal que espera en milisegundos
End;

End.
