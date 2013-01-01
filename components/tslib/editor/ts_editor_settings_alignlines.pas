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

unit ts_Editor_Settings_AlignLines;

{$mode delphi}

//*****************************************************************************

interface

uses
  Classes, Forms, Controls;

//=============================================================================

type
  TAlignLinesSettings = class(TPersistent)
  private
    FAlignInParagraphs    : Boolean;
    FKeepSpaceAfterToken  : Boolean;
    FKeepSpaceBeforeToken : Boolean;
    FRemoveWhiteSpace     : Boolean;
  public
    procedure AfterConstruction; override;
    procedure AssignTo(Dest: TPersistent); override;
    procedure Assign(Source: TPersistent); override;

  published
    property AlignInParagraphs: Boolean
      read FAlignInParagraphs write FAlignInParagraphs;

    property RemoveWhiteSpace: Boolean
      read FRemoveWhiteSpace write FRemoveWhiteSpace;

    property KeepSpaceBeforeToken: Boolean
      read FKeepSpaceBeforeToken write FKeepSpaceBeforeToken;

    property KeepSpaceAfterToken: Boolean
      read FKeepSpaceAfterToken write FKeepSpaceAfterToken;

  end;

//*****************************************************************************

implementation

//*****************************************************************************
// construction and destruction                                          BEGIN
//*****************************************************************************

procedure TAlignLinesSettings.AfterConstruction;
begin
  inherited AfterConstruction;
end;

//*****************************************************************************
// construction and destruction                                            END
//*****************************************************************************

//*****************************************************************************
// public methods                                                        BEGIN
//*****************************************************************************

procedure TAlignLinesSettings.AssignTo(Dest: TPersistent);
var
  ALS: TAlignLinesSettings;
begin
  if Dest is TAlignLinesSettings then
  begin
    ALS := TAlignLinesSettings(Dest);
    ALS.KeepSpaceAfterToken  := KeepSpaceAfterToken;
    ALS.KeepSpaceBeforeToken := KeepSpaceBeforeToken;
    ALS.AlignInParagraphs    := AlignInParagraphs;
    ALS.RemoveWhiteSpace     := RemoveWhiteSpace;
  end
  else
    inherited AssignTo(Dest);
end;

procedure TAlignLinesSettings.Assign(Source: TPersistent);
var
  ALS: TAlignLinesSettings;
begin
  if Source is TAlignLinesSettings then
  begin
    ALS := TAlignLinesSettings(Source);
    KeepSpaceAfterToken  := ALS.KeepSpaceAfterToken;
    KeepSpaceBeforeToken := ALS.KeepSpaceBeforeToken;
    AlignInParagraphs    := ALS.AlignInParagraphs;
    RemoveWhiteSpace     := ALS.RemoveWhiteSpace;
  end
  else
    inherited Assign(Source);
end;

//*****************************************************************************
// public methods                                                          END
//*****************************************************************************

end.

