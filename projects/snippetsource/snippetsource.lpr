program SnippetSource;

{$MODE DELPHI}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  SysUtils, Forms, pascalscript, lazcontrols, luicontrols,
  virtualtreeview_package, cmdbox,
  virtualdbtreeexlaz,

  { you can add units after this }
  ts.Editor.Manager, ts.Core.ComponentInspector, ts.Core.Logger.Channel.IPC,
  ts.Core.Logger.Interfaces, ts.Core.Logger, ts.Core.SharedLogger,
  ts.Core.Utils,

  SnippetSource.Forms.Main, SnippetSource.Resources, SnippetSource.Forms.Console;

{$R *.res}

begin
{$IF DECLARED(UseHeapTrace)}
  if FileExists('trace.trc') then
    DeleteFile('trace.trc');
  GlobalSkipIfNoLeaks := True; // supported as of debugger version 3.1.1
  SetHeapTraceOutput('trace.trc');
{$ENDIF}
  Application.Scaled := True;
  Application.Title := 'SnippetSource';
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
