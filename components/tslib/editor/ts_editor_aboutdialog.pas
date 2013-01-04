{
  Copyright (C) 2013 Tim Sinaeve tim.sinaeve@gmail.com

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}

unit ts_Editor_AboutDialog;

{$mode delphi}

{
  TODO: use TVirtualTreeviewers

  Credits:

    Lazarus - FPC Free Pascal development team
    TVirtualTreeView Mike Lischke, LCL port by Luiz Américo Pereira Câmara with modifications by Tim Sinaeve
    TSynEdit
    DWScript engine Matthias Ackermann, maintained by Eric Grange; FPC port by Alexander Shishkin
    TTreeViewPresenter, datatemplates Stefan Glienke
    Anchor Docking Mattias Gaertner
    RTTI controls Mattias Gaertner
    TDirectoryWatch Iztok Kacin, Cromis, FPC port by Tim Sinaeve
    TRichMemo Dmitry 'skalogryz' Boyarintsev
    NativeXML Nils Haeck M.Sc.
    luicontrols Luiz Américo Pereira Câmara
    luicomponents Luiz Américo Pereira Câmara
    MultiLog Luiz Américo Pereira Câmara
    SynUniHighlighter Kirill Burtsev and Vitaly Nevzorov, ported to FPC by Tom Lisjac and Tim Sinaeve
    Silk Icons
    other icons
    GetText translation powered

}

//*****************************************************************************

interface

uses
  SysUtils, Forms, StdCtrls, ExtCtrls, Buttons, Classes, Contnrs,

  LResources, ComCtrls, Grids, ActnList,

  VirtualTrees,

  ts_Core_VersionInfo, ts_Core_TreeViewPresenter, ts_Core_ColumnDefinitions;

//=============================================================================

type
  TfrmAbout = class(TForm)
    aclMain: TActionList;
    actClose: TAction;
    btnClose: TButton;
    {$region 'designer controls' /fold}
    grpLine           : TGroupBox;
    imgMain: TImage;
    lbBuildDate: TLabel;
    lbLCLVersion: TLabel;
    lblFileVersion: TLabel;
    lblFPCVersion: TLabel;
    lblLegalCopyright: TLabel;
    lblTargetCPU: TLabel;
    lblTargetOS: TLabel;
    lblURL: TLabel;
    lblWidgetSet: TLabel;
    pgcMain: TPageControl;
    pnlBuildDate: TPanel;
    pnlFileVersion: TPanel;
    pnlFPCVersion: TPanel;
    pnlLCLVersion: TPanel;
    pnlName: TPanel;
    pnlTargetCPU: TPanel;
    pnlTargetOS: TPanel;
    pnlWidgetSet: TPanel;
    tsAbout: TTabSheet;
    tsCredits: TTabSheet;
    vstCredits: TVirtualStringTree;
    procedure actCloseExecute(Sender: TObject);
    procedure lblURLClick(Sender: TObject);
    procedure lblURLDblClick(Sender: TObject);
    {$endregion}
  private
    FVersionInfo : TVersionInfo;
    FTVP         : TTreeViewPresenter;
    FCredits     : TObjectList;

    procedure FillCredits;

  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

  end;

  TCredit = class(TPersistent)
  strict private
    FAuthor: string;
    FName: string;
    FURL: string;

    procedure SetAuthor(AValue: string);
    procedure SetName(AValue: string);
    procedure SetURL(AValue: string);
  published
    property Name: string
      read FName write SetName;

    property Author: string
      read FAuthor write SetAuthor;

    property URL: string
      read FURL write SetURL;

  end;

procedure ShowAboutDialog;

//*****************************************************************************

implementation

{$R *.lfm}

uses
  LCLIntf;

procedure ShowAboutDialog;
var
  F : TfrmAbout;
begin
  F := TfrmAbout.Create(Application);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

//*****************************************************************************
// construction and destruction                                          BEGIN
//*****************************************************************************

procedure TfrmAbout.AfterConstruction;
begin
  inherited AfterConstruction;
  FVersionInfo := TVersionInfo.Create(Self);
  pnlFPCVersion.Caption     := FVersionInfo.FPCVersion;
  pnlLCLVersion.Caption     := FVersionInfo.LCLVersion;
  pnlTargetCPU.Caption      := FVersionInfo.TargetCPU;
  pnlTargetOS.Caption       := FVersionInfo.TargetOS;
  pnlBuildDate.Caption      := FVersionInfo.BuildDate;
  pnlWidgetSet.Caption      := FVersionInfo.WidgetSet;
  pnlFileVersion.Caption    := FVersionInfo.FileVersion;
  pnlName.Caption           := FVersionInfo.ProductName + ' ' + FVersionInfo.ProductVersion;;
  lblURL.Caption            := FVersionInfo.URL;
  lblLegalCopyright.Caption := FVersionInfo.LegalCopyright;
  imgMain.Picture.Assign(FVersionInfo.Icon);
  FCredits := TObjectList.Create(True);
  FillCredits;
  FTVP := TTreeViewPresenter.Create(Self);
  FTVP.ColumnDefinitions.AddColumn('Name', dtString, 100);
  FTVP.ColumnDefinitions.AddColumn('Author', dtString, 200, 100, 300);
  FTVP.ListMode := True;
  FTVP.ItemsSource := FCredits;
  FTVP.TreeView := vstCredits;
end;

procedure TfrmAbout.BeforeDestruction;
begin
  FreeAndNil(FCredits);
  FreeAndNil(FTVP);
  FreeAndNil(FVersionInfo);

  inherited BeforeDestruction;
end;

//*****************************************************************************
// construction and destruction                                            END
//*****************************************************************************

//*****************************************************************************
// property access methods                                               BEGIN
//*****************************************************************************

procedure TCredit.SetName(AValue: string);
begin
  if FName = AValue then Exit;
  FName := AValue;
end;

procedure TCredit.SetURL(AValue: string);
begin
  if FURL = AValue then Exit;
  FURL := AValue;
end;

procedure TCredit.SetAuthor(AValue: string);
begin
  if FAuthor = AValue then Exit;
  FAuthor := AValue;
end;

//*****************************************************************************
// property access methods                                                 END
//*****************************************************************************

//*****************************************************************************
// action handlers                                                       BEGIN
//*****************************************************************************

procedure TfrmAbout.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmAbout.lblURLClick(Sender: TObject);
begin
  OpenURL(FVersionInfo.URL);
end;

procedure TfrmAbout.lblURLDblClick(Sender: TObject);
begin
  OpenURL(FVersionInfo.URL);
end;

//*****************************************************************************
// action handlers                                                         END
//*****************************************************************************

//*****************************************************************************
// private methods                                                       BEGIN
//*****************************************************************************

procedure TfrmAbout.FillCredits;

  procedure AddCredit(const AName: string; const AAuthor: string; const AURL: string);
  var
    C: TCredit;
  begin
    C := TCredit.Create;
    C.Name := AName;
    C.Author := AAuthor;
    C.URL := AURL;
    FCredits.Add(C);
  end;

begin
  AddCredit(
    'Virtual TreeView',
    'Mike Lischke, FPC port by Luiz Américo Pereira Câmara with modifications by Tim Sinaeve',
    'http://www.soft-gems.net/'
  );
  AddCredit(
    'Lazarus',
    'Lazarus development team',
    'http://www.lazarus.freepascal.org/'
  );
  AddCredit(
    'FPC',
    'Free Pascal development team',
    'http://www.freepascal.org/'
  );
  AddCredit(
    'Anchor Docking',
    'Mattias Gaertner, with modifications by Tim Sinaeve',
    ''
  );
  AddCredit(
    'RTTI controls',
    'Mattias Gaertner',
    ''
  );
  AddCredit(
    'NativeXML',
    'Nils Haeck',
    'http://www.simdesign.nl/xml.html'
  );
  AddCredit(
    'SynEdit',
    'Martin Waldenburg, and currently maintained by the Lazarus team.',
    'http://sourceforge.net/apps/mediawiki/synedit/index.php?title=SynEdit_Home_Page'
  );
  AddCredit(
    'SynUniHighlighter',
    'Kirill Burtsev and Vitaly Nevzorov, FPC port by Tom Lisjac with modifications by Tim Sinaeve',
    ''
  );
  AddCredit(
    'Multilog',
    'Luiz Américo Pereira Câmara',
    ''
  );
  AddCredit(
    'DWScript',
    'Matthias Ackermann, maintained by Eric Grange; FPC port by Alexander Shishkin',
    'http://code.google.com/p/dwscript/'
  );
  AddCredit(
    'Silk Icons',
    'Mark James',
    'http://www.famfamfam.com/lab/icons/silk/'
  );
  AddCredit(
    'Fugue Icons',
    'Yusuke Kamiyamane',
    'http://p.yusukekamiyamane.com/'
  );
  vstCredits.Header.MainColumn := 1;
  vstCredits.Header.Options := vstCredits.Header.Options + [hoAutoSpring, hoAutoResize];
end;

//*****************************************************************************
// private methods                                                         END
//*****************************************************************************

end.

