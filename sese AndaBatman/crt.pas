
Unit crt;
{$unitpath ../dos}

Interface

// Constantes de color
Const
  Black = 0;
  Blue = 1;
  Green = 2;
  Cyan = 3;
  Red = 4;
  Magenta = 5;
  Brown = 6;
  LightGray = 7;
  DarkGray = 8;
  LightBlue = 9;
  LightGreen = 10;
  LightCyan = 11;
  LightRed = 12;
  LightMagenta = 13;
  Yellow = 14;
  White = 15;

Procedure clrscr;
// Limpiar la pantalla
Procedure gotoxy(x, y: integer);
// Posicionar el cursor en la pantalla
Procedure textcolor(color: byte);
// Cambiar el color del texto
Procedure textbackground(color: byte);
// Cambiar el color de fondo
Function readkey: char;
// Leer una tecla sin esperar Enter
Procedure delay(ms: longint);
// Pausar por cierto tiempo (en milisegundos)

Implementation

Uses 
dos, sysutils;

Procedure clrscr;
Begin
  // Este comando envía el código ANSI para limpiar la pantalla
  write(#27'[2J');
End;

Procedure gotoxy(x, y: integer);
Begin
  // Código ANSI para mover el cursor a la posición (x, y)
  write(#27'[', y, ';', x, 'H');
End;

Procedure textcolor(color: byte);
Begin
  // Código ANSI para cambiar el color del texto
  write(#27'[', 30 + color, 'm');
End;

Procedure textbackground(color: byte);
Begin
  // Código ANSI para cambiar el color del fondo
  write(#27'[', 40 + color, 'm');
End;

Function readkey: char;

Var 
  ch: char;
Begin
  // Implementación simplificada - espera y lee un caracter
  readln(ch);
  readkey := ch;
End;

Procedure delay(ms: longint);
Begin
  // Pausa por el tiempo especificado en milisegundos
  Sleep(ms);
End;

End.
