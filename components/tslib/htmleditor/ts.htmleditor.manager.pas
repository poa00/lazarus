{
  Copyright (C) 2013-2023 Tim Sinaeve tim.sinaeve@gmail.com

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
}

unit ts.HtmlEditor.Manager;

{$MODE DELPHI}

interface

uses
  Classes, SysUtils, ActnList, Dialogs, Menus, Controls, Contnrs, Forms,

  ts.HtmlEditor.Interfaces;

type
  THtmlEditorViewList = TComponentList;

type
  TdmHtmlEditorManager = class(TDataModule, IHtmlEditorManager, IHtmlEditorActions,
    IHtmlEditorEvents)
    aclActions                : TActionList;
    actAddParagraph1: TAction;
    actAlignCenter            : TAction;
    actAlignCenter1: TAction;
    actAlignJustify           : TAction;
    actAlignJustify1: TAction;
    actAlignLeft              : TAction;
    actAlignLeft1: TAction;
    actAlignRight             : TAction;
    actAlignRight1: TAction;
    actBold                   : TAction;
    actBold1: TAction;
    actBulletList             : TAction;
    actBulletList1: TAction;
    actClear                  : TAction;
    actClear1: TAction;
    actClipboardMenu          : TAction;
    actClipboardMenu1: TAction;
    actCopy                   : TAction;
    actCopy1: TAction;
    actCut                    : TAction;
    actCut1: TAction;
    actDecFontSize            : TAction;
    actDecFontSize1: TAction;
    actDecIndent              : TAction;
    actDecIndent1: TAction;
    actDeleteColumn1: TAction;
    actDeleteRow1: TAction;
    actDeleteTable1: TAction;
    actEditParagraphStyle1: TAction;
    actEditSelectedItem1: TAction;
    actEditTextStyle1: TAction;
    actFileMenu               : TAction;
    actFileMenu1: TAction;
    actGoBack                 : TAction;
    actGoForward              : TAction;
    actIncFontSize            : TAction;
    actIncFontSize1: TAction;
    actIncIndent              : TAction;
    actIncIndent1: TAction;
    actInsertBulletList1: TAction;
    actInsertColumnAfter1: TAction;
    actInsertColumnBefore1: TAction;
    actInsertHyperLink        : TAction;
    actInsertHyperLink1: TAction;
    actInsertImage            : TAction;
    actInsertImage1: TAction;
    actInsertMenu             : TAction;
    actInsertMenu1: TAction;
    actInsertRowAfter1: TAction;
    actInsertRowBefore1: TAction;
    actInsertTable1: TAction;
    actOpenInDefaultBrowser: TAction;
    actItalic                 : TAction;
    actItalic1: TAction;
    actNumberedList           : TAction;
    actNumberedList1: TAction;
    actOpen                   : TAction;
    actOpen1: TAction;
    actPaste                  : TAction;
    actPaste1: TAction;
    actRedo                   : TAction;
    actRedo1: TAction;
    actRefresh                : TAction;
    actSave                   : TAction;
    actSave1: TAction;
    actSaveAs                 : TAction;
    actSaveAs1: TAction;
    actSelectAll              : TAction;
    actSelectAll1: TAction;
    actSelectionMenu          : TAction;
    actSelectionMenu1: TAction;
    actSelectMenu             : TAction;
    actSelectMenu1: TAction;
    actSelectTable1: TAction;
    actSetBackgroundColor     : TAction;
    actSetBackgroundColor1: TAction;
    actSetFont                : TAction;
    actSetFont1: TAction;
    actSetFontColor           : TAction;
    actSetFontColor1: TAction;
    actSettingsMenu           : TAction;
    actSettingsMenu1: TAction;
    actShowDevTools           : TAction;
    actShowPreview1: TAction;
    actShowSpecialCharacters1: TAction;
    actShowStructureViewer1: TAction;
    actShowTaskManager        : TAction;
    actStrikeThrough          : TAction;
    actStrikeThrough1: TAction;
    actTableMenu1: TAction;
    actToggleEditMode         : TAction;
    actToggleSourceVisible    : TAction;
    actToggleWordWrap1: TAction;
    actUnderline              : TAction;
    actUnderline1: TAction;
    actUndo                   : TAction;
    actUndo1: TAction;
    dlgColor                  : TColorDialog;
    dlgFont                   : TFontDialog;
    dlgOpen                   : TOpenDialog;
    dlgSave                   : TSaveDialog;
    imlMain                   : TImageList;
    ppmClipboard              : TPopupMenu;
    ppmFile                   : TPopupMenu;
    ppmHtmlEditor             : TPopupMenu;
    ppmInsert                 : TPopupMenu;
    ppmSelect                 : TPopupMenu;
    ppmSelection              : TPopupMenu;
    ppmSettings               : TPopupMenu;
    ppmTable                  : TPopupMenu;

    {$REGION 'action handlers'}
    procedure aclActionsExecute(AAction: TBasicAction; var Handled: Boolean);
    procedure actAddParagraphExecute(Sender: TObject);
    procedure actAlignCenterExecute(Sender: TObject);
    procedure actAlignJustifyExecute(Sender: TObject);
    procedure actAlignLeftExecute(Sender: TObject);
    procedure actAlignRightExecute(Sender: TObject);
    procedure actBoldExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actCutExecute(Sender: TObject);
    procedure actDecIndentExecute(Sender: TObject);
    procedure actGoBackExecute(Sender: TObject);
    procedure actGoForwardExecute(Sender: TObject);
    procedure actIncIndentExecute(Sender: TObject);
    procedure actInsertHyperLinkExecute(Sender: TObject);
    procedure actInsertImageExecute(Sender: TObject);
    procedure actItalicExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actOpenInDefaultBrowserExecute(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure actRedoExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actShowDevToolsExecute(Sender: TObject);
    procedure actShowTaskManagerExecute(Sender: TObject);
    procedure actStrikeThroughExecute(Sender: TObject);
    procedure actToggleEditModeExecute(Sender: TObject);
    procedure actToggleSourceVisibleExecute(Sender: TObject);
    procedure actUnderlineExecute(Sender: TObject);
    procedure actUndoExecute(Sender: TObject);
    {$ENDREGION}

  private
    FViews      : THtmlEditorViewList;
    FActiveView : IHtmlEditorView;
    FEvents     : IHtmlEditorEvents;
    FToolViews  : IHtmlEditorToolViews;

  protected
    {$REGION 'property access methods'}
    function GetActionList: TActionList;
    function GetActions: IHtmlEditorActions;
    function GetActiveView: IHtmlEditorView;
    function GetClipboardPopupMenu: TPopupMenu;
    function GetEditorPopupMenu: TPopupMenu;
    function GetEvents: IHtmlEditorEvents;
    function GetFilePopupMenu: TPopupMenu;
    function GetInsertPopupMenu: TPopupMenu;
    function GetItem(AName: string): TContainedAction;
    function GetSelectionPopupMenu: TPopupMenu;
    function GetSelectPopupMenu: TPopupMenu;
    function GetSettingsPopupMenu: TPopupMenu;
    function GetToolViews: IHtmlEditorToolViews;
    function GetView(AIndex: Integer): IHtmlEditorView;
    function GetViewByName(AName: string): IHtmlEditorView;
    function GetViewCount: Integer;
    procedure SetActiveView(const AValue: IHtmlEditorView);
    {$ENDREGION}

    function AddView(
      const AName     : string = '';
      const AFileName : string = ''
    ): IHtmlEditorView;
    function DeleteView(AIndex: Integer): Boolean;
    procedure ClearViews;
    procedure UpdateActions;

    property ActionList: TActionList
      read GetActionList;

    { Delegates the implementation of IEditorEvents to an internal object. }
    property Events: IHtmlEditorEvents
      read GetEvents implements IHtmlEditorEvents;

    property Actions: IHtmlEditorActions
      read GetActions;

    property ActiveView: IHtmlEditorView
      read GetActiveView write SetActiveView;

    property ToolViews: IHtmlEditorToolViews
      read GetToolViews;

    property Views[AIndex: Integer]: IHtmlEditorView
      read GetView;

    property ViewByName[AName: string]: IHtmlEditorView
      read GetViewByName;

    property ViewCount: Integer
      read GetViewCount;

  public
    procedure AfterConstruction; override;
    destructor Destroy; override;

    procedure InitializePopupMenus;
    procedure RegisterToolViews;
    procedure ShowToolView(
      const AName : string;
      AShowModal  : Boolean;
      ASetFocus   : Boolean
    );

    procedure BuildEditorPopupMenu;
    procedure BuildSelectionPopupMenu;
    procedure BuildSelectPopupMenu;
    procedure BuildFilePopupMenu;
    procedure BuildClipboardPopupMenu;
    procedure BuildSettingsPopupMenu;

    property ClipboardPopupMenu: TPopupMenu
      read GetClipboardPopupMenu;

    property EditorPopupMenu: TPopupMenu
      read GetEditorPopupMenu;

    property FilePopupMenu: TPopupMenu
      read GetFilePopupMenu;

    property InsertPopupMenu: TPopupMenu
      read GetInsertPopupMenu;

    property SelectPopupMenu: TPopupMenu
      read GetSelectPopupMenu;

    property SelectionPopupMenu: TPopupMenu
      read GetSelectionPopupMenu;

    property SettingsPopupMenu: TPopupMenu
      read GetSettingsPopupMenu;

  end;

implementation

{$R *.lfm}

uses
  LCLIntf,

  ts.Core.Utils, ts.Core.Logger,
  ts.HtmlEditor.View, ts.HtmlEditor.Events, ts.HtmlEditor.ToolViews,
  ts.HtmlEditor.Resources;

{$REGION 'construction and destruction'}
procedure TdmHtmlEditorManager.AfterConstruction;
begin
  inherited AfterConstruction;
  FViews     := THtmlEditorViewList.Create(False);
  FEvents    := THtmlEditorEvents.Create(Self);
  FToolViews := THtmlEditorToolViews.Create(Self);
  InitializePopupMenus;
  RegisterToolViews;
end;

destructor TdmHtmlEditorManager.Destroy;
begin
  FActiveView := nil;
  FEvents     := nil;
  FToolViews  := nil;
  FreeAndNil(FViews);
  inherited Destroy;
end;
{$ENDREGION}

{$REGION 'action handlers'}
procedure TdmHtmlEditorManager.actAlignRightExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.AlignRight := True;
  end;
end;

procedure TdmHtmlEditorManager.actBoldExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    //
  end;
end;

procedure TdmHtmlEditorManager.actClearExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.Clear;
  end;
end;

procedure TdmHtmlEditorManager.actCopyExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.Copy;
  end;
end;

procedure TdmHtmlEditorManager.actCutExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.Cut;
  end;
end;

procedure TdmHtmlEditorManager.actDecIndentExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.DecIndent;
  end;
end;

procedure TdmHtmlEditorManager.actGoBackExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.GoBack;
  end;
end;

procedure TdmHtmlEditorManager.actGoForwardExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.GoForward;
  end;
end;

procedure TdmHtmlEditorManager.actRefreshExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.Refresh;
  end;
end;

procedure TdmHtmlEditorManager.actShowDevToolsExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.ShowDevTools;
  end;
end;

procedure TdmHtmlEditorManager.actIncIndentExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.IncIndent;
  end;
end;

procedure TdmHtmlEditorManager.actInsertHyperLinkExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.InsertHyperlink;
  end;
end;

procedure TdmHtmlEditorManager.actInsertImageExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.InsertImage;
  end;
end;

procedure TdmHtmlEditorManager.actItalicExecute(Sender: TObject);
begin
  ShowMessage(SNotImplementedYet);
end;

procedure TdmHtmlEditorManager.actOpenExecute(Sender: TObject);
begin
  if dlgOpen.Execute then
  begin
    ActiveView.LoadFromFile(dlgOpen.FileName);
    ActiveView.FileName := dlgOpen.FileName;
  end;
end;

procedure TdmHtmlEditorManager.actOpenInDefaultBrowserExecute(Sender: TObject);
var
  S : string;
begin
  if Assigned(ActiveView) then
  begin
    S := ActiveView.Source;
    Logger.Info('Opening URL: %s', [S]);
    OpenURL(S);
  end;
end;

procedure TdmHtmlEditorManager.actPasteExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.Paste;
  end;
end;

procedure TdmHtmlEditorManager.actRedoExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.Redo;
  end;
end;

procedure TdmHtmlEditorManager.actSelectAllExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.SelectAll;
  end;
end;

procedure TdmHtmlEditorManager.actShowTaskManagerExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.ShowTaskManager;
  end;
end;

procedure TdmHtmlEditorManager.actStrikeThroughExecute(Sender: TObject);
begin
  ShowMessage(SNotImplementedYet);
end;

procedure TdmHtmlEditorManager.actToggleEditModeExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.EditMode := (Sender as TAction).Checked;
  end;
end;

procedure TdmHtmlEditorManager.actToggleSourceVisibleExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.SourceVisible := (Sender as TAction).Checked;
  end;
end;

procedure TdmHtmlEditorManager.actUnderlineExecute(Sender: TObject);
begin
  ShowMessage(SNotImplementedYet);
end;

procedure TdmHtmlEditorManager.actUndoExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.Undo;
  end;
end;

procedure TdmHtmlEditorManager.actAlignLeftExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.AlignLeft := True;
  end;
end;

procedure TdmHtmlEditorManager.actAlignCenterExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.AlignCenter := True;
  end;
end;

procedure TdmHtmlEditorManager.actAddParagraphExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.AddParagraph;
  end;
end;

procedure TdmHtmlEditorManager.aclActionsExecute(AAction: TBasicAction;
  var Handled: Boolean);
begin
  if (AAction is TContainedAction) and not (AAction is TCustomHintAction) then
  begin
    Logger.Action(AAction);
  end;
end;

procedure TdmHtmlEditorManager.actAlignJustifyExecute(Sender: TObject);
begin
  if Assigned(ActiveView) then
  begin
    ActiveView.AlignJustify := True;
  end;
end;
{$ENDREGION}

{$REGION 'property access methods'}
function TdmHtmlEditorManager.GetClipboardPopupMenu: TPopupMenu;
begin
  Result := ppmClipboard;
end;

function TdmHtmlEditorManager.GetFilePopupMenu: TPopupMenu;
begin
  Result := ppmFile;
end;

function TdmHtmlEditorManager.GetInsertPopupMenu: TPopupMenu;
begin
  Result := ppmInsert;
end;

function TdmHtmlEditorManager.GetSelectionPopupMenu: TPopupMenu;
begin
  Result := ppmSelection;
end;

function TdmHtmlEditorManager.GetSelectPopupMenu: TPopupMenu;
begin
  Result := ppmSelect;
end;

function TdmHtmlEditorManager.GetSettingsPopupMenu: TPopupMenu;
begin
  Result  := ppmSettings;
end;

function TdmHtmlEditorManager.GetActionList: TActionList;
begin
  Result := aclActions;
end;

function TdmHtmlEditorManager.GetActions: IHtmlEditorActions;
begin
  Result := Self as IHtmlEditorActions;
end;

function TdmHtmlEditorManager.GetActiveView: IHtmlEditorView;
begin
  if not Assigned(FActiveView) then
    raise Exception.Create('No active view assigned!');
  Result := FActiveView;
end;

procedure TdmHtmlEditorManager.SetActiveView(const AValue: IHtmlEditorView);
begin
  if AValue <> FActiveView then
  begin
    FActiveView := AValue;
  end;
end;

function TdmHtmlEditorManager.GetItem(AName: string): TContainedAction;
begin
  Result := aclActions.ActionByName(AName);
end;

function TdmHtmlEditorManager.GetEditorPopupMenu: TPopupMenu;
begin
  Result := ppmHtmlEditor;
end;

function TdmHtmlEditorManager.GetEvents: IHtmlEditorEvents;
begin
  Result := FEvents;
end;

function TdmHtmlEditorManager.GetToolViews: IHtmlEditorToolViews;
begin
  Result := FToolViews;
end;

function TdmHtmlEditorManager.GetView(AIndex: Integer): IHtmlEditorView;
begin
   if (AIndex > -1) and (AIndex < FViews.Count) then
  begin
    Result := FViews[AIndex] as IHtmlEditorView;
  end
  else
    Result := nil;
end;

function TdmHtmlEditorManager.GetViewByName(AName: string): IHtmlEditorView;
var
  I : Integer;
  B : Boolean;
begin
  I := 0;
  B := False;
  while (I < FViews.Count) and not B do
  begin
    B := FViews[I].Name = AName;
    if not B then
      Inc(I);
  end;
  if B then
    Result := FViews[I] as IHtmlEditorView
  else
    Result := nil;
end;

function TdmHtmlEditorManager.GetViewCount: Integer;
begin
  Result := FViews.Count;
end;
{$ENDREGION}

{$REGION 'protected methods'}
function TdmHtmlEditorManager.AddView(const AName: string;
  const AFileName: string): IHtmlEditorView;
var
  V : IHtmlEditorView;
begin
  V := THtmlEditorView.Create(Self);
  // if no name is provided, the view will get an automatically generated one.
  if AName <> '' then
    V.Form.Name := AName;
  V.FileName := AFileName;
  V.Form.Caption := '';
  FViews.Add(V.Form);
  Result := V as IHtmlEditorView;
  FActiveView := V;
end;

function TdmHtmlEditorManager.DeleteView(AIndex: Integer): Boolean;
begin
  { TODO -oTS : Needs implementation }
  Result := False;
end;

procedure TdmHtmlEditorManager.ClearViews;
begin
  FViews.Clear;
end;

procedure TdmHtmlEditorManager.UpdateActions;
var
  B : Boolean;
begin
  B := Assigned(ActiveView);
  actOpenInDefaultBrowser.Enabled := B and not ActiveView.IsSourceEmpty;
  actGoBack.Enabled               := B and ActiveView.CanGoBack;
  actGoForward.Enabled            := B and ActiveView.CanGoForward;
  actToggleEditMode.Checked       := B and ActiveView.EditMode;
  actToggleSourceVisible.Checked  := B and ActiveView.SourceVisible;
  B := B and ActiveView.EditMode;
  actPaste.Enabled           := B;
  actAlignCenter.Enabled     := B;
  actAlignLeft.Enabled       := B;
  actAlignRight.Enabled      := B;
  actAlignJustify.Enabled    := B;
  actBold.Enabled            := B;
  actClear.Enabled           := B;
  actBulletList.Enabled      := B;
  actIncFontSize.Enabled     := B;
  actIncIndent.Enabled       := B;
  actDecFontSize.Enabled     := B;
  actDecIndent.Enabled       := B;
  actInsertHyperLink.Enabled := B;
  actInsertImage.Enabled     := B;
  actItalic.Enabled          := B;
  actUnderline.Enabled       := B;
  actStrikeThrough.Enabled   := B;
  actUndo.Enabled            := B;
  actRedo.Enabled            := B;
  actOpen.Enabled            := B;
end;
{$ENDREGION}

{$REGION 'public methods'}
procedure TdmHtmlEditorManager.InitializePopupMenus;
begin
  BuildSelectionPopupMenu;
  BuildSelectPopupMenu;
  BuildFilePopupMenu;
  BuildClipboardPopupMenu;
  BuildSettingsPopupMenu;
  BuildEditorPopupMenu;
end;

procedure TdmHtmlEditorManager.RegisterToolViews;
begin
  //ToolViews.Register(TStructureToolView, nil, 'Structure');
end;

procedure TdmHtmlEditorManager.ShowToolView(const AName: string;
  AShowModal: Boolean; ASetFocus: Boolean);
var
  ETV : IHtmlEditorToolView;
  TV  : IHtmlEditorToolView;
begin
  ETV := ToolViews[AName];
  for TV in ToolViews do
  begin
    if TV <> ETV then
      TV.Visible := False;
  end;
  if not ETV.Visible then
  begin
    if not AShowModal then
    begin
      { This for example can allow the owner to dock the toolview in the main
        application workspace. }
      Events.DoShowToolView(ETV);
      ETV.Visible := True;
    end
    else
    begin
      ETV.Form.ShowModal;
    end;
  end;
  ETV.UpdateView;
  if ASetFocus then
    ETV.SetFocus;
end;

procedure TdmHtmlEditorManager.BuildEditorPopupMenu;
var
  MI : TMenuItem;
begin
  MI := ppmHtmlEditor.Items;
  MI.Clear;
  AddMenuItem(MI, actCut);
  AddMenuItem(MI, actCopy);
  AddMenuItem(MI, actPaste);
  AddMenuItem(MI);
  AddMenuItem(MI, actRefresh);
  AddMenuItem(MI);
  AddMenuItem(MI, SelectionPopupMenu);
  AddMenuItem(MI, FilePopupMenu);
  AddMenuItem(MI, InsertPopupMenu);
  AddMenuItem(MI, SelectPopupMenu);
  AddMenuItem(MI, ClipboardPopupMenu);
  AddMenuItem(MI, SettingsPopupMenu);
  AddMenuItem(MI);
  AddMenuItem(MI, actUndo);
  AddMenuItem(MI, actRedo);
end;

procedure TdmHtmlEditorManager.BuildSelectionPopupMenu;
var
  MI : TMenuItem;
begin
  MI := SelectionPopupMenu.Items;
  MI.Clear;
  MI.Action := actSelectionMenu;
  AddMenuItem(MI, actBold);
  AddMenuItem(MI, actItalic);
  AddMenuItem(MI, actUnderline);
  AddMenuItem(MI, actStrikeThrough);
  AddMenuItem(MI);
  AddMenuItem(MI, actAlignLeft);
  AddMenuItem(MI, actAlignCenter);
  AddMenuItem(MI, actAlignRight);
  AddMenuItem(MI, actAlignJustify);
  AddMenuItem(MI);
  AddMenuItem(MI, actIncIndent);
  AddMenuItem(MI, actDecIndent);
  AddMenuItem(MI);
  AddMenuItem(MI, actBulletList);
  AddMenuItem(MI, actNumberedList);
  AddMenuItem(MI);
  AddMenuItem(MI, actSetFontColor);
  AddMenuItem(MI, actSetBackgroundColor);
  AddMenuItem(MI, actSetFont);
end;

procedure TdmHtmlEditorManager.BuildSelectPopupMenu;
var
  MI : TMenuItem;
begin
  MI := SelectPopupMenu.Items;
  MI.Clear;
  MI.Action := actSelectMenu;
  AddMenuItem(MI, actClear);
end;

procedure TdmHtmlEditorManager.BuildFilePopupMenu;
var
  MI : TMenuItem;
begin
  MI := FilePopupMenu.Items;
  MI.Clear;
  MI.Action := actFileMenu;
  AddMenuItem(MI, actOpen);
  AddMenuItem(MI, actSave);
  AddMenuItem(MI, actSaveAs);
end;

procedure TdmHtmlEditorManager.BuildClipboardPopupMenu;
var
  MI : TMenuItem;
begin
  MI := ClipboardPopupMenu.Items;
  MI.Clear;
  MI.Action := actClipboardMenu;
end;

procedure TdmHtmlEditorManager.BuildSettingsPopupMenu;
var
  MI : TMenuItem;
begin
  MI := SettingsPopupMenu.Items;
  MI.Clear;
  MI.Action := actSettingsMenu;
end;
{$ENDREGION}

end.

