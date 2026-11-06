Unit iniciar_archivo;
{$H+}

{ ================================================================ }
{  Iniciar_archivo.pas - Abrir y cerrar la base de datos           }
{ ================================================================ }

Interface

Uses entidad;

Procedure iniciarArchivo(Var arch: TextFile);
Procedure cerrarArchivo(Var arch: TextFile);

Implementation

Procedure iniciarArchivo(Var arch: TextFile);
Begin
  Assign(arch, RUTA);
  {$I-}
  Reset(arch);
  {$I+}
  If IOResult <> 0 Then
    Rewrite(arch);
End;

Procedure cerrarArchivo(Var arch: TextFile);
Begin
  Close(arch);
End;

End.