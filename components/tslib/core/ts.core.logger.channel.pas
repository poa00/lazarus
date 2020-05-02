{
  Copyright (C) 2013-2020 Tim Sinaeve tim.sinaeve@gmail.com

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

unit ts.Core.Logger.Channel;

{$MODE DELPHI}

interface

uses
  SysUtils, Classes,
  fgl,

  ts.Core.Logger.Interfaces;

type
  TCustomLogChannel = class(TInterfacedObject, ILogChannel)
  private
    FEnabled     : Boolean;
    FAutoConnect : Boolean;

  protected
    {$REGION 'property access methods'}
    function GetPort: Integer; virtual;
    function GetEnabled: Boolean; virtual;
    procedure SetEnabled(const Value: Boolean); virtual;
    function GetConnected: Boolean; virtual;
    function GetAutoConnect: Boolean;
    procedure SetAutoConnect(const Value: Boolean);
    {$ENDREGION}

    { Will try to (re)connect automatically to a disconnected channel if a
      new message is written.  }
    property AutoConnect: Boolean
      read GetAutoConnect write SetAutoConnect;

    { Indicates that messages from the Logger object will be sent through this
      channel. }
    property Enabled: Boolean
      read GetEnabled write SetEnabled;

    { True when the channel is connected with the receiver instance.  }
    property Connected: Boolean
      read GetConnected;

    property Port: Integer
      read GetPort;

  public
    constructor Create(AEnabled: Boolean = True); virtual;

    function Write(const AMsg: TLogMessage): Boolean; virtual; abstract;

    function Connect: Boolean; virtual;
    function Disconnect: Boolean; virtual;

  end;

  { TChannelList }

  TChannelList = class(TInterfacedObject, IChannelList)
  private
    FList : TFPGInterfacedObjectList<ILogChannel>;

  protected
    function GetCount: Integer;
    function GetItems(AIndex:Integer): ILogChannel;

  public
    constructor Create;
    destructor Destroy; override;

    function Add(const AChannel: ILogChannel) :Integer;
    procedure Remove(AChannel: ILogChannel);

    property Count: Integer
      read GetCount;

    property Items[AIndex:Integer]: ILogChannel
      read GetItems;
  end;

implementation

{$REGION 'TChannelList'}

{$REGION 'construction and destruction'}
constructor TChannelList.Create;
begin
  FList := TFPGInterfacedObjectList<ILogChannel>.Create;
end;

destructor TChannelList.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;
{$ENDREGION}

{$REGION 'property access methods'}
function TChannelList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TChannelList.GetItems(AIndex:Integer): ILogChannel;
begin
  Result := FList[AIndex];
end;
{$ENDREGION}

{$REGION 'public methods'}
function TChannelList.Add(const AChannel: ILogChannel): Integer;
begin
  Result := FList.Add(AChannel);
end;

procedure TChannelList.Remove(AChannel: ILogChannel);
begin
  FList.Remove(AChannel);
end;
{$ENDREGION}
{$ENDREGION}

{$REGION 'TCustomLogChannel'}
{$REGION 'construction and destruction'}
constructor TCustomLogChannel.Create(AEnabled: Boolean);
begin
  inherited Create;
  Enabled := AEnabled;
end;
{$ENDREGION}

{$REGION 'property access methods'}
function TCustomLogChannel.GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

procedure TCustomLogChannel.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
end;

function TCustomLogChannel.GetAutoConnect: Boolean;
begin
  Result := FAutoConnect;
end;

procedure TCustomLogChannel.SetAutoConnect(const Value: Boolean);
begin
  FAutoConnect := Value;
end;

function TCustomLogChannel.GetConnected: Boolean;
begin
  Result := False; // to be overridden in descendants
end;

function TCustomLogChannel.GetPort: Integer;
begin
  Result := 0;  // to be overridden in descendants
end;
{$ENDREGION}

{$REGION 'public methods'}
function TCustomLogChannel.Connect: Boolean;
begin
  Result := False; // to be overridden in descendants
end;

function TCustomLogChannel.Disconnect: Boolean;
begin
  Result := False; // to be overridden in descendants
end;
{$ENDREGION}
{$ENDREGION}
end.

