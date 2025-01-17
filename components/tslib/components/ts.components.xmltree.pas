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

{
  The Original Code is xmltree.pas, Version 0.0.27 '. The Initial Developer of
  the Original Code is Moritz Franckenstein (maf-soft@gmx.net). Portions created
  by the Initial Developer are Copyright (C) 2001. All Rights Reserved.
  The original code is available at Yahoo! groups at
  http://de.groups.yahoo.com/group/VirtualTreeview_de/files/

  This component has been rewritten almost completely in order to support the
  later Delphis and FPC/Lazarus. Some of the major modifications include:
  - Unicode support in Delphi 2009 and later
  - Compatibility with FPC 2.6.x and above
  - Support for VirtualTree version 5.0.x and above
  - Uses NativeXML to parse the XML. This is many times faster than using
    MSXML and makes this component compile for multiple platforms.
  - Customizable node paint options
  - many bugfixes
}

unit ts.Components.XMLTree;

interface

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF}

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ImgList,
{$IFDEF FPC}
  LMessages,
{$ENDIF}
{$IFDEF WINDOWS}
  Windows,
{$ENDIF}
  VirtualTrees,

  ts.Core.Logger, ts.Core.NativeXml,

  ts.Components.XMLTree.Editors, ts.Components.XMLTree.NodeAttributes;

{$IFDEF FPC}
type
  NativeUint = PtrInt;
  TWMChar    = TLMChar;
{$ENDIF}


const
  // Helper message to decouple node change handling from edit handling.
  WM_STARTEDITING = 1000 + 778;

const
  DEFAULT_BGCOLOR_UNKNOWN = clRed;
  DEFAULT_BGCOLOR_ROOT    = $00E8E8E8; // DOCUMENT_NODE light grey
  DEFAULT_BGCOLOR_COMMENT = $00C1FFFF; // COMMENT_NODE   yellow
  DEFAULT_BGCOLOR_TEXT    = $00FFD7D7;
  // TEXT_NODE, CDATA_SECTION_NODE light blue navy
  DEFAULT_BGCOLOR_ATTRIBUTE = $00FFE8E8; // ATTRIBUTE_NODE white
  DEFAULT_BGCOLOR_ELEMENT = $00ECFFEC; // ELEMENT_NODE without ChildNodes green
  DEFAULT_BGCOLOR_NODE    = $00E5E5E5;
  // ELEMENT_NODE without ChildNodes light gray

  DEFAULT_FGCOLOR_UNKNOWN   = clBlack;
  DEFAULT_FGCOLOR_ROOT      = clBlack;
  DEFAULT_FGCOLOR_COMMENT   = clGray;
  DEFAULT_FGCOLOR_TEXT      = clBlack;
  DEFAULT_FGCOLOR_ATTRIBUTE = clBlack;
  DEFAULT_FGCOLOR_ELEMENT   = clBlack;
  DEFAULT_FGCOLOR_NODE      = clBlack;

{$REGION 'default VST options'}
const
  DEFAULT_VST_SELECTIONOPTIONS = [
    { Prevent user from selecting with the selection rectangle in multiselect
      mode. }
//    toDisableDrawSelection,
    { Entries other than in the main column can be selected, edited etc. }
    toExtendedFocus
    { Hit test as well as selection highlight are not constrained to the text
      of a node. }
//    toFullRowSelect,
    { Constrain selection to the same level as the selection anchor. }
//    toLevelSelectConstraint,
    { Allow selection, dragging etc. with the middle mouse button. This and
      toWheelPanning are mutual exclusive. }
//    toMiddleClickSelect,
    { Allow more than one node to be selected. }
//    toMultiSelect,
    { Allow selection, dragging etc. with the right mouse button. }
//    toRightClickSelect,
    { Constrain selection to nodes with same parent. }
//    toSiblingSelectConstraint,
    { Center nodes vertically in the client area when scrolling into view. }
//    toCenterScrollIntoView,
    { Simplifies draw selection, so a node's caption does not need to intersect
      with the selection rectangle. }
//    toSimpleDrawSelection
  ];
  DEFAULT_VST_MISCOPTIONS = [
    { Register tree as OLE accepting drop target }
//    toAcceptOLEDrop,
    { Show checkboxes/radio buttons. }
//    toCheckSupport,
    { Node captions can be edited. }
    toEditable,
    { Fully invalidate the tree when its window is resized (CS_HREDRAW/CS_VREDRAW).}
//    toFullRepaintOnResize,
    { Use some special enhancements to simulate and support grid behavior. }
    toGridExtensions,
    { Initialize nodes when saving a tree to a stream. }
    toInitOnSave,
    { Tree behaves like TListView in report mode. }
    toReportMode,
    { Toggle node expansion state when it is double clicked. }
    toToggleOnDblClick,
    { Support for mouse panning (wheel mice only). This option and
      toMiddleClickSelect are mutal exclusive, where panning has precedence. }
    toWheelPanning,
    { The tree does not allow to be modified in any way. No action is executed
      and node editing is not possible. }
//    toReadOnly,
    { When set then GetNodeHeight will trigger OnMeasureItem to allow variable
      node heights. }
    toVariableNodeHeight,
    { Start node dragging by clicking anywhere in it instead only on the caption
      or image. Must be used together with toDisableDrawSelection. }
//    toFullRowDrag,
    { Allows changing a node's height via mouse. }
//    toNodeHeightResize,
    { Allows to reset a node's height to FDefaultNodeHeight via a double click. }
//    toNodeHeightDblClickResize,
    { Editing mode can be entered with a single click }
    toEditOnClick,
    { Editing mode can be entered with a double click }
    toEditOnDblClick
  ];
  DEFAULT_VST_PAINTOPTIONS = [
    { Avoid drawing the dotted rectangle around the currently focused node. }
    toHideFocusRect,
    { Paint tree as would it always have the focus }
    toPopupMode,
    { Display collapse/expand buttons left to a node. }
    toShowButtons,
    { Show the dropmark during drag'n drop operations. }
    toShowDropmark,
    { Display horizontal lines to simulate a grid. }
    toShowHorzGridLines,
    { Use the background image if there's one. }
    toShowBackground,
    { Show static background instead of a tiled one. }
    toStaticBackground,
    { Show lines also at top level (does not show the hidden/internal root
      node). }
    toShowRoot,
    { Display tree lines to show hierarchy of nodes. }
    toShowTreeLines,
    { Display vertical lines (depending on columns) to simulate a grid. }
    toShowVertGridLines,
    { Draw UI elements (header, tree buttons etc.) according to the current
      theme if enabled (Windows XP+ only, application must be themed). }
    toThemeAware,
    { Enable alpha blending for ghosted nodes or those which are being
      cut/copied. }
    toUseBlendedImages,
    { Enable alpha blending for node selections. }
    toUseBlendedSelection
  ];
  DEFAULT_VST_HEADEROPTIONS = [
    { Adjust a column so that the header never exceeds the client width of the
      owner control. }
    hoAutoResize,
    { Resizing columns with the mouse is allowed. }
    hoColumnResize,
    { Allows a column to resize itself to its largest entry. }
    hoDblClickResize,
    { Dragging columns is allowed. }
//    hoDrag,
    { Header captions are highlighted when mouse is over a particular column. }
//    hoHotTrack,
    { Header items with the owner draw style can be drawn by the application
      via event. }
//    hoOwnerDraw,
    { Header can only be dragged horizontally. }
//    hoRestrictDrag,
    { Show application defined header hint. }
    hoShowHint,
    { Show header images. }
    hoShowImages,
    { Allow visible sort glyphs. }
//    hoShowSortGlyphs,
    { Distribute size changes of the header to all columns, which are sizable
      and have the coAutoSpring option enabled. hoAutoResize must be enabled
      too. }
//    hoAutoSpring,
    { Fully invalidate the header (instead of subsequent columns only) when a
      column is resized. }
    hoFullRepaintOnResize,
    { Disable animated resize for all columns. }
    hoDisableAnimatedResize,
    { Allow resizing header height via mouse. }
//    hoHeightResize,
    { Allow the header to resize itself to its default height. }
//    hoHeightDblClickResize
    { Header is visible. }
    hoVisible
    { Clicks on the header will make the clicked column the SortColumn or toggle
      sort direction if it already was the sort column }
    // hoHeaderClickAutoSort
  ];
  DEFAULT_VST_STRINGOPTIONS = [
    { If set then the caption is automatically saved with the tree node,
      regardless of what is saved in the user data. }
//    toSaveCaptions,
    { Show static text in a caption which can be differently formatted than the
      caption but cannot be edited. }
//    toShowStaticText,
    { Automatically accept changes during edit if the user finishes editing
      other then VK_RETURN or ESC. If not set then changes are cancelled. }
//    toAutoAcceptEditChange
  ];
  DEFAULT_VST_ANIMATIONOPTIONS = [
    { Expanding and collapsing a node is animated (quick window scroll). }
//    toAnimatedToggle,
    { Do some advanced animation effects when toggling a node. }
//    toAdvancedAnimatedToggle
  ];
  DEFAULT_VST_AUTOOPTIONS = [
    { Expand node if it is the drop target for more than a certain time. }
    toAutoDropExpand,
    { Nodes are expanded (collapsed) when getting (losing) the focus. }
//    toAutoExpand,
    { Scroll if mouse is near the border while dragging or selecting. }
    toAutoScroll,
    { Scroll as many child nodes in view as possible after expanding a node. }
    toAutoScrollOnExpand,
    { Sort tree when Header.SortColumn or Header.SortDirection change or sort
      node if child nodes are added. }
//    toAutoSort,
    { Large entries continue into next column(s) if there's no text in them
      (no clipping). }
    toAutoSpanColumns,
    { Checkstates are automatically propagated for tri state check boxes. }
    toAutoTristateTracking,
    { Node buttons are hidden when there are child nodes, but all are invisible.}
//    toAutoHideButtons,
    { Delete nodes which where moved in a drag operation (if not directed
      otherwise). }
    toAutoDeleteMovedNodes,
    { Disable scrolling a node or column into view if it gets focused. }
//    toDisableAutoscrollOnFocus,
    { Change default node height automatically if the system's font scale is
      set to big fonts. }
    toAutoChangeScale,
    { Frees any child node after a node has been collapsed (HasChildren flag
      stays there). }
//    toAutoFreeOnCollapse,
    { Do not center a node horizontally when it is edited. }
    toDisableAutoscrollOnEdit,
    { When set then columns (if any exist) will be reordered from lowest index
      to highest index and vice versa when the tree's bidi mode is changed. }
    toAutoBidiColumnOrdering
  ];
{$ENDREGION}

type
  PNodeData = ^TNodeData;
  TNodeData = record
    XMLNode  : TXmlNode;
    XMLPath  : string;
    NodeType : TNodeType;
  end;

  TXMLTree = class;

  TCheckNodeEvent = procedure(
        ASender      : TXMLTree;
        ANode        : PVirtualNode;
    var ANewXMLNode  : TXmlNode;
    var ANewNodeType : TNodeType;
    var AAdd         : Boolean
  ) of object;

  TGetBackColorEvent = procedure(
        ASender     : TXMLTree;
        AParentNode : PVirtualNode;
        AXMLNode    : TXmlNode;
        ANodeType   : TNodeType;
    var ABackColor  : TColor
  ) of object;

  TExpandedState = class
  strict private
    FInUse    : Boolean;
    FFocFound : PVirtualNode;
    FTopFound : PVirtualNode;
    FList     : TStringList;
    FFocPath  : string;
    FTopPath  : string;

  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    property List: TStringList
      read FList;

    property InUse: Boolean
      read FInUse write FInUse;

    property TopPath: string
      read FTopPath write FTopPath;

    property FocPath: string
      read FFocPath write FFocPath;

    property TopFound: PVirtualNode
      read FTopFound write FTopFound;

    property FocFound: PVirtualNode
      read FFocFound write FFocFound;
  end;

  TXMLTree = class(TCustomVirtualStringTree)
  private
    FExpandedState       : TExpandedState;
    FNodeAttributes      : TNodeAttributes;
    FOnCheckNode         : TCheckNodeEvent;
    FOnGetBackColor      : TGetBackColorEvent;
    FXMLDocument         : TNativeXml;
    FValueColumn         : Integer;

    function GetXMLDocument: TNativeXml;
    function GetXML: string;
    procedure SetXML(Value: string);
    function GetOptions: TStringTreeOptions;
    procedure SetOptions(const AValue: TStringTreeOptions);
    function GetNodeXML(ANode: PVirtualNode): string;
    procedure SetNodeXML(ANode: PVirtualNode; const Value: string);

    procedure WMChar(var Message: TWMChar); message LM_CHAR;

    function AddChildren(
      ANode    : PVirtualNode;
      AXMLNode : TXmlNode
    ): Cardinal;
    function AddChild(
      ANode       : PVirtualNode;
      ANewXMLNode : TXmlNode
    ): Boolean; reintroduce;

    procedure IterateCallback(
          ASender : TBaseVirtualTree;
          ANode   : PVirtualNode;
          AData   : Pointer;
      var AAbort  : Boolean
    );

    function GetDefaultNodeType(AXMLNode: TXmlNode): TNodeType;

  protected
    {$REGION 'TVirtualStringTree overrides'}
    function GetOptionsClass: TTreeOptionsClass; override;
    procedure DoInitNode(Parent, ANode: PVirtualNode;
      var InitStates: TVirtualNodeInitStates); override;
    procedure DoFreeNode(ANode: PVirtualNode); override;
    procedure DoGetText(ANode: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; var Text: string); override;
    function DoCreateEditor(Node: PVirtualNode; Column: TColumnIndex)
      : IVTEditLink; override;
    function DoGetImageIndex(ANode: PVirtualNode; Kind: TVTImageKind;
      Column: TColumnIndex; var Ghosted: Boolean;
      var Index: Integer): TCustomImageList; override;
    procedure DoPaintText(ANode: PVirtualNode; const Canvas: TCanvas;
      Column: TColumnIndex; TextType: TVSTTextType); override;
    procedure DoBeforeItemErase(
      Canvas: TCanvas;
      ANode : PVirtualNode;
      {$IFDEF FPC}const {$ENDIF} ItemRect: TRect;
      var Color      : TColor;
      var EraseAction: TItemEraseAction
    ); override;

    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoBeforeCellPaint(
          Canvas        : TCanvas;
          ANode         : PVirtualNode;
          Column        : TColumnIndex;
          CellPaintMode : TVTCellPaintMode;
          CellRect      : TRect;
      var ContentRect   : TRect
    ); override;
    procedure DoCanEdit(ANode: PVirtualNode; Column: TColumnIndex;
      var Allowed: Boolean); override;
    procedure DoNewText(ANode: PVirtualNode; Column: TColumnIndex;
    {$IFDEF FPC}const {$ENDIF} Text: string); override;
    function DoGetNodeHint(ANode: PVirtualNode; Column: TColumnIndex;
      var LineBreakStyle: TVTTooltipLineBreakStyle): string; override;
    procedure DoMeasureItem(TargetCanvas: TCanvas; Node: PVirtualNode;
      var NodeHeight: Integer); override;
    procedure DoTextDrawing(var PaintInfo: TVTPaintInfo; {$IFDEF FPC}const {$ENDIF}
      Text: string;
      CellRect: TRect; DrawFormat: Cardinal); override;
    function DoBeforeItemPaint(Canvas: TCanvas; Node: PVirtualNode;
      {$IFDEF FPC}const {$ENDIF} ItemRect: TRect): Boolean; override;
    procedure DoAfterCellPaint(Canvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; {$IFDEF FPC}const {$ENDIF} CellRect: TRect); override;
    procedure DoAfterItemErase(Canvas: TCanvas; Node: PVirtualNode;
      {$IFDEF FPC}const {$ENDIF} ItemRect: TRect); override;
    procedure DoAfterItemPaint(Canvas: TCanvas; Node: PVirtualNode;
      {$IFDEF FPC}const {$ENDIF} ItemRect: TRect); override;
    procedure DoAfterPaint(Canvas: TCanvas); override;
    {$ENDREGION}

    procedure DoCheckNode(Parent: PVirtualNode; var ANewXMLNode: TXmlNode;
      var ANewNodeType: TNodeType; var AAdd: Boolean); virtual;

    procedure DoGetBackColor(
          ANode      : PVirtualNode;
          AColumn    : TColumnIndex;
      var ABackColor : TColor
    ); virtual;

    procedure InitializeNodeAttributes;
    procedure InitializeHeader;
    // message handlers
    procedure WMStartEditing(var AMessage: TMessage); message WM_STARTEDITING;

    // hidden properties
    property LineMode;

  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure Clear; override;

    // helpers
    function GetData(ANode: PVirtualNode): PNodeData;
    function GetXMLNode(ANode: PVirtualNode): TXmlNode;
    function GetNodeType(ANode: PVirtualNode): TNodeType;
    function GetElementType(ANode: PVirtualNode): TsdElementType;
    function GetXmlPath(AXMLNode: TXmlNode): string;

    function FindNode(
      AXMLNode  : TXmlNode;
      ADoInit   : Boolean = False;
      ADoExpand : Boolean = False
    ): PVirtualNode; overload;

    function FindNode(
      const AXPath    : string;
            ADoInit   : Boolean = False;
            ADoExpand : Boolean = False
    ): PVirtualNode; overload;

    procedure ExpandedStateClear;
    procedure ExpandedStateRestore;
    procedure ExpandedStateSave;

    procedure RefreshNode(
      ANode   : PVirtualNode;
      AParent : Boolean = False
    );
    procedure NewNode(
      ANode        : PVirtualNode;
      ANewNodeType : TNodeType;
      AValue       : string = '';
      AName        : string = '';
      ABefore      : Boolean = False;
      AAddBreak    : Boolean = False;
      AXMLNode     : TXmlNode = nil
    );
    procedure DeleteNode(Node: PVirtualNode; Reindex: Boolean = True);

    property XMLDocument: TNativeXml
      read GetXMLDocument;

    property NodeXML[ANode: PVirtualNode]: string
      read GetNodeXML write SetNodeXML;

  published
    {$REGION 'published properties'}
    property XML: string
      read GetXML write SetXML;

    property NodeAttributes: TNodeAttributes
      read FNodeAttributes;

    property OnCheckNode: TCheckNodeEvent
      read FOnCheckNode write FOnCheckNode;

    property OnGetBackColor: TGetBackColorEvent
      read FOnGetBackColor write FOnGetBackColor;

    property TreeOptions : TStringTreeOptions
      read GetOptions write SetOptions;

    property Action;
    property Align;
    property Alignment;
    property Anchors;
    property AnimationDuration;
    property AutoExpandDelay;
    property AutoScrollDelay;
    property AutoScrollInterval;
    property Background;
    property BackgroundOffsetX;
    property BackgroundOffsetY;
    property BiDiMode;
    property BorderStyle;
    property ButtonFillMode;
    property ButtonStyle;
    property BorderWidth;
    property ChangeDelay;
    property CheckImageKind;
    property ClipboardFormats;
    property Color;
    property Colors;
    property Constraints;
    property CustomCheckImages;
    property DefaultPasteMode;
    property DefaultText;
    property DragCursor;
    property DragHeight;
    property DragKind;
    property DragImageKind;
    property DragMode;
    property DragOperations;
    property DragType;
    property DragWidth;
    property DrawSelectionMode;
    property EditDelay;
    property Enabled;
    property Font;
    property Header;
    property HintMode;
    property HotCursor;
    property Images;
    property IncrementalSearch;
    property IncrementalSearchDirection;
    property IncrementalSearchStart;
    property IncrementalSearchTimeout;
    property Indent;
    property LineStyle;
    property Margin;
    property NodeAlignment;
    property NodeDataSize;
    property OperationCanceled;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property RootNodeCount;
    property ScrollBarOptions;
    property SelectionBlendFactor;
    property SelectionCurveRadius;
    property ShowHint;
    property StateImages;
    property TabOrder;
    property TabStop default True;
    property TextMargin;
    property Visible;
    property WantTabs;
    {$ifndef FPC}
    property BevelEdges;
    property BevelInner;
    property BevelOuter;
    property BevelKind;
    property BevelWidth;
    property Ctl3D;
    property HintAnimation;
    property ParentCtl3D;
    {$ENDIF}
    property OnAdvancedHeaderDraw;
    property OnAfterAutoFitColumn;
    property OnAfterAutoFitColumns;
    property OnAfterCellPaint;
    property OnAfterColumnExport;
    property OnAfterColumnWidthTracking;
    property OnAfterGetMaxColumnWidth;
    property OnAfterHeaderExport;
    property OnAfterHeaderHeightTracking;
    property OnAfterItemErase;
    property OnAfterItemPaint;
    property OnAfterNodeExport;
    property OnAfterPaint;
    property OnAfterTreeExport;
    property OnBeforeAutoFitColumn;
    property OnBeforeAutoFitColumns;
    property OnBeforeCellPaint;
    property OnBeforeColumnExport;
    property OnBeforeColumnWidthTracking;
    property OnBeforeGetMaxColumnWidth;
    property OnBeforeHeaderExport;
    property OnBeforeHeaderHeightTracking;
    property OnBeforeItemErase;
    property OnBeforeItemPaint;
    property OnBeforeNodeExport;
    property OnBeforePaint;
    property OnBeforeTreeExport;
    property OnCanSplitterResizeColumn;
    property OnChange;
    property OnChecked;
    property OnChecking;
    property OnClick;
    property OnCollapsed;
    property OnCollapsing;
    property OnColumnClick;
    property OnColumnDblClick;
    property OnColumnExport;
    property OnColumnResize;
    property OnColumnWidthDblClickResize;
    property OnColumnWidthTracking;
    property OnCompareNodes;
    property OnContextPopup;
    property OnCreateDataObject;
    property OnCreateDragManager;
    property OnCreateEditor;
    property OnDblClick;
    property OnDragAllowed;
    property OnDragOver;
    property OnDragDrop;
    property OnDrawText;
    property OnEditCancelled;
    property OnEdited;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnExpanded;
    property OnExpanding;
    property OnFocusChanged;
    property OnFocusChanging;
    property OnFreeNode;
    property OnGetCellIsEmpty;
    property OnGetCursor;
    property OnGetHeaderCursor;
    property OnGetText;
    property OnPaintText;
    property OnGetHelpContext;
    property OnGetImageIndex;
    property OnGetImageIndexEx;
    property OnGetImageText;
    property OnGetHint;
    property OnGetLineStyle;
    property OnGetNodeDataSize;
    property OnGetPopupMenu;
    property OnGetUserClipboardFormats;
    property OnHeaderClick;
    property OnHeaderDblClick;
    property OnHeaderDragged;
    property OnHeaderDraggedOut;
    property OnHeaderDragging;
    property OnHeaderDraw;
    property OnHeaderDrawQueryElements;
    property OnHeaderHeightDblClickResize;
    property OnHeaderHeightTracking;
    property OnHeaderMouseDown;
    property OnHeaderMouseMove;
    property OnHeaderMouseUp;
    property OnHotChange;
    property OnIncrementalSearch;
    property OnInitChildren;
    property OnInitNode;
    property OnKeyAction;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnLoadNode;
    property OnMeasureItem;
    property OnMeasureTextWidth;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnNewText;
    property OnNodeCopied;
    property OnNodeCopying;
    property OnNodeExport;
    property OnNodeHeightDblClickResize;
    property OnNodeHeightTracking;
    property OnNodeMoved;
    property OnNodeMoving;
    property OnPaintBackground;
    property OnRenderOLEData;
    property OnResetNode;
    property OnResize;
    property OnSaveNode;
    property OnScroll;
    property OnShortenString;
    property OnShowScrollbar;
    property OnStartDock;
    property OnStartDrag;
    property OnStateChange;
    property OnStructureChange;
    property OnUpdating;
    {$ENDREGION}
  end;


implementation


uses
{$IFDEF FPC}
  LCLType,
{$ENDIF}
  TypInfo;

procedure PaintBtnEllipsis(DC: HDC; Rect: TRect; Pressed: Boolean);
var
  Flags: Integer;
begin
  Flags := 0;
{$IFDEF WINDOWS}
  if Pressed then Flags := BF_FLAT;
  DrawEdge(DC, Rect, EDGE_RAISED, BF_RECT or BF_MIDDLE or Flags);
  Flags := (Rect.Right - Rect.Left) div 2 - 1 + Ord(Pressed);
  PatBlt(DC, Rect.Left + Flags, Rect.Top + Flags, 2, 2, BLACKNESS);
  PatBlt(DC, Rect.Left + Flags - 3, Rect.Top + Flags, 2, 2, BLACKNESS);
  PatBlt(DC, Rect.Left + Flags + 3, Rect.Top + Flags, 2, 2, BLACKNESS);
{$ENDIF}
end;

{$REGION 'documentation'}
// xeElement,     //  0 normal element <name {attr}>[value][sub-elements]</name>
// xeAttribute,   //  1 attribute ( name='value' or name="value")
// xeCharData,    //  2 character data in a node
// xeComment,     //  3 comment <!--{comment}-->
// xeCData,       //  4 literal data <![CDATA[{data}]]>
// xeCondSection, //  5 conditional section <![ IGNORE / INCLUDE [ markup ]]>
// xeDeclaration, //  6 xml declaration <?xml{declaration}?>
// xeStylesheet,  //  7 stylesheet <?xml-stylesheet{stylesheet}?>
// xeDocType,     //  8 doctype dtd declaration <!DOCTYPE{spec}>
// xeDtdElement,  //  9 dtd element <!ELEMENT >
// xeDtdAttList,  // 10 dtd attlist <!ATTLIST >
// xeDtdEntity,   // 11 dtd entity <!ENTITY >
// xeDtdNotation, // 12 dtd notation <!NOTATION >
// xeInstruction, // 13 processing instruction <?...?>
// xeWhiteSpace,  // 14 chardata with only whitespace
// xeQuotedText,  // 15 quoted text: "bla" or 'bla'
// xeEndTag,      // 16 </...> and signal function in binary xml
// xeError        // 17 some error or unknown
{$ENDREGION}

type
  TVKSet = set of Byte;

var
  VK_EDIT_KEYS : TVKSet = [
    Ord('0')..Ord('Z'),
    VK_OEM_1..VK_OEM_102,
    VK_MULTIPLY..VK_DIVIDE
  ];

const
  ELEMENTTYPES_WITH_NO_CHILDREN = [
    xeAttribute,
    xeCharData,
    xeComment,
    xeCData,
    xeCondSection,
    xeDeclaration,
    xeStylesheet,
    xeDocType,
    xeInstruction,
    xeWhiteSpace,
    xeQuotedText,
    xeEndTag
  ];


{$REGION 'TXmlNodeHelper'}
type
  TXmlNodeHelper = class helper for TXmlNode
  private
    function ProcessXPath(const StartNode: TXmlNode; XPath: string;
      const ResultNodes: TList; const StopWhenFound: Boolean): Integer;

  public
    function SelectNode(const XPath: string): TXmlNode;
    function SelectNodes(XPath: string; const Nodes: TList): Integer;
  end;

function TXmlNodeHelper.ProcessXPath(const StartNode: TXmlNode; XPath: string;
  const ResultNodes: TList; const StopWhenFound: Boolean): Integer;
var
  Recursive    : Boolean;
  SlashPos     : Integer;
  NodeName     : string;
  I            : Integer;
  Child        : TXmlNode;
  NodesToSearch: TList;
label
  FindFirstSlash;
begin
  Result := 0;
  if not Assigned(ResultNodes) then
    Exit;
  Recursive := False;
FindFirstSlash:
  SlashPos := Pos('/', XPath);
  case SlashPos of
    0:
      begin // no slash present
        NodeName := XPath;
        XPath    := '';
      end;
    1:
      begin // starting with a slash; this was '//'
        Recursive := True;
        XPath     := Copy(XPath, 2, Length(XPath));
        goto FindFirstSlash;
      end;
  else
    begin
      NodeName := Copy(XPath, 1, SlashPos - 1);
      XPath    := Copy(XPath, SlashPos + 1, Length(XPath));
    end;
  end;

  if (NodeName = '') and (XPath = '') then
  begin
    ResultNodes.Add(StartNode);
    Result := 1;
    Exit;
  end
  else if NodeName = '.' then
  begin
    Assert(not Recursive, 'The expression "//." is not supported.');
    Result := Result + ProcessXPath(StartNode, XPath, ResultNodes,
      StopWhenFound);
    if StopWhenFound and (Result > 0) then
      Exit;
  end
  else if NodeName = '..' then
  begin
    Assert(not Recursive, 'The expression "//.." is not supported.');
    Result := Result + ProcessXPath(StartNode, XPath, ResultNodes,
      StopWhenFound);
    if StopWhenFound and (Result > 0) then
      Exit;
  end
  else if NodeName = '*' then
  begin
    Assert(not Recursive, 'The expression "//*" is not supported.');
    NodeName := '';
  end;

  if Recursive then
  begin
    NodesToSearch := TList.Create;
    try
      StartNode.FindNodes(UTF8String(NodeName), NodesToSearch);
      for I := 0 to NodesToSearch.Count - 1 do
      begin
        Child  := NodesToSearch[I];
        Result := Result + ProcessXPath(Child, XPath, ResultNodes,
          StopWhenFound);
        if StopWhenFound and (Result > 0) then
          Exit;
      end;
    finally
      NodesToSearch.Free;
    end;
  end
  else
  begin
    for I := 0 to StartNode.NodeCount - 1 do
    begin
      Child := StartNode.Nodes[I];
      if (NodeName = '') or (string(Child.Name) = NodeName) then
      begin
        Result := Result + ProcessXPath(Child, XPath, ResultNodes,
          StopWhenFound);
        if StopWhenFound and (Result > 0) then
          Exit;
      end;
    end;
  end;
end;

function TXmlNodeHelper.SelectNode(const XPath: string): TXmlNode;
var
  Nodes: TList;
begin
  Nodes := TList.Create;
  try
    if Copy(XPath, 1, 1) = '/' then
    begin
      ProcessXPath(Self.Document.Root, Copy(XPath, 2, 2), Nodes, True);
    end
    else
    begin
      ProcessXPath(Self, XPath, Nodes, True);
    end;
    if Nodes.Count > 0 then
      Result := TXmlNode(Nodes[0])
    else
      Result := nil;
  finally
    Nodes.Free;
  end;
end;

function TXmlNodeHelper.SelectNodes(XPath: string; const Nodes: TList): Integer;
begin
  if Copy(XPath, 1, 1) = '/' then
  begin
    Result := ProcessXPath(Self.Document.Root, Copy(XPath, 2, 2), Nodes, False);
  end
  else
  begin
    Result := ProcessXPath(Self, XPath, Nodes, False);
  end;
end;
{$ENDREGION}

{$REGION 'construction and destruction'}
procedure TXMLTree.AfterConstruction;
begin
  inherited;
  FXMLDocument                    := TNativeXml.Create(Self);
  FXMLDocument.PreserveWhiteSpace := True;
  NodeDataSize                 := SizeOf(TNodeData);
  Color                        := clWhite;
  Header.Height                := 18;
  DefaultNodeHeight            := 18;
  Indent                       := 18;
  LineStyle                    := lsSolid;
  LineMode                     := lmBands;
  DragType                     := dtVCL; // dtOLE not supported yet
  DragOperations               := [doMove];
  Margin                       := 0;
  DrawSelectionMode            := smBlendedRectangle;
  HintMode                     := hmHintAndDefault;
  WantTabs                     := True;
  DefaultPasteMode             := amInsertAfter;
  Font.Name                    := 'Consolas';
  EditDelay                    := 0;
  IncrementalSearch            := isNone;
  Colors.GridLineColor := clMedGray;
  Colors.FocusedSelectionColor := clGray;
  //SelectionBlendFactor         := 100;

  Header.Options               := DEFAULT_VST_HEADEROPTIONS;
  TreeOptions.SelectionOptions := DEFAULT_VST_SELECTIONOPTIONS;
  TreeOptions.MiscOptions      := DEFAULT_VST_MISCOPTIONS;
  TreeOptions.PaintOptions     := DEFAULT_VST_PAINTOPTIONS;
  TreeOptions.StringOptions    := DEFAULT_VST_STRINGOPTIONS;
  TreeOptions.AnimationOptions := DEFAULT_VST_ANIMATIONOPTIONS;
  TreeOptions.AutoOptions      := DEFAULT_VST_AUTOOPTIONS;

  FNodeAttributes := TNodeAttributes.Create(Self);
  InitializeNodeAttributes;

  FExpandedState := TExpandedState.Create;

  InitializeHeader;
end;

procedure TXMLTree.BeforeDestruction;
begin
  FNodeAttributes.Free;
  FExpandedState.Free;
  inherited;
end;
{$ENDREGION}

{$REGION 'property access mehods'}
function TXMLTree.GetNodeXML(ANode: PVirtualNode): string;
begin
  Result := string(GetData(ANode).XMLNode.WriteToString);
end;

{ Note: Raises an exception when the Xml contains errors. }

procedure TXMLTree.SetNodeXML(ANode: PVirtualNode; const Value: string);
var
  NX : TNativeXml;
  P  : PNodeData;
begin
  NX := TNativeXml.Create(Self);
  try
    NX.ReadFromString(UTF8String(Value));
    if NX.IsEmpty then
      raise Exception.Create('Parse Error: invalid XML document!');
    P := GetData(ANode);
    P.XMLNode.Assign(NX.Root);
    P.XMLPath := GetXmlPath(P.XMLNode);
    RefreshNode(ANode, False);
  finally
    NX.Free;
  end;
end;

function TXMLTree.GetOptions: TStringTreeOptions;
begin
  Result := inherited TreeOptions as TStringTreeOptions;
end;

procedure TXMLTree.SetOptions(const AValue: TStringTreeOptions);
begin
  inherited TreeOptions.Assign(AValue);
end;

function TXMLTree.GetOptionsClass: TTreeOptionsClass;
begin
  Result := TStringTreeOptions;
end;

function TXMLTree.GetXML: string;
begin
  if Assigned(FXMLDocument) then
  begin
    Result := FXMLDocument.WriteToString;
  end
  else
    Result := '';
end;

procedure TXMLTree.SetXML(Value: string);
var
  WasCleared: Boolean;
begin
  BeginUpdate;
  WasCleared := XMLDocument.IsEmpty;
  Clear;
  XMLDocument.ReadFromString(UTF8String(Value));
  try
    if not WasCleared then
      ExpandedStateSave;

    AddChildren(nil, FXMLDocument.Root);

    if not WasCleared then
      ExpandedStateRestore
  finally
    if not WasCleared then
      ExpandedStateClear;
  end;
  EndUpdate;
end;

function TXMLTree.GetXMLDocument: TNativeXml;
begin
  Result := FXMLDocument;
end;
{$ENDREGION}

{$REGION 'message handlers'}
{ This message was posted by ourselves from the node change handler above to
  decouple that change event and our intention to start editing a node. This
  is necessary to avoid interferences between nodes editors potentially created
  for an old edit action and the new one we start here. }

procedure TXMLTree.WMStartEditing(var AMessage: TMessage);
var
  Node: PVirtualNode;
begin
  Node := Pointer(AMessage.WParam);
  { Note: the test whether a node can really be edited is done in the
    OnEditing event. }
  EditNode(Node, 1);
end;
{$ENDREGION}

{$REGION 'event dispatch methods'}
procedure TXMLTree.DoCheckNode(Parent: PVirtualNode; var ANewXMLNode: TXmlNode;
  var ANewNodeType: TNodeType; var AAdd: Boolean);
begin
  if Assigned(FOnCheckNode) then
    FOnCheckNode(Self, Parent, ANewXMLNode, ANewNodeType, AAdd);
end;

procedure TXMLTree.DoInitNode(Parent, ANode: PVirtualNode;
  var InitStates: TVirtualNodeInitStates);
var
  ND: PNodeData;
begin
  ND := GetData(ANode);
  Include(ANode.States, vsInitialized);
  Include(ANode.States, vsMultiline);
  Include(ANode.States, vsHeightMeasured);
  if not Assigned(Parent) then
    Include(InitStates, ivsExpanded);
  if AddChildren(ANode, ND.XMLNode) > 0 then
    Include(InitStates, ivsHasChildren);
  inherited;
end;

procedure TXMLTree.DoMeasureItem(TargetCanvas: TCanvas; Node: PVirtualNode;
  var NodeHeight: Integer);
var
  I : Integer;
  H : Integer;
begin
  inherited;
  TargetCanvas.Font := Font;
  NodeHeight        := Integer(DefaultNodeHeight);
  for I             := 0 to Header.Columns.Count - 1 do
  begin
    H := ComputeNodeHeight(TargetCanvas, Node, I);
    if H > NodeHeight then
      NodeHeight := H;
  end;
  // needed to avoid multiline text drawing issues
  if NodeHeight > Integer(DefaultNodeHeight) then
    NodeHeight := NodeHeight + 4;
end;

procedure TXMLTree.DoFreeNode(ANode: PVirtualNode);
var
  ND: PNodeData;
begin
  ND := GetData(ANode);
  if Assigned(ND.XMLNode) then
  begin
    ND.XMLNode  := nil;
    ND.XMLPath  := '';
    ND.NodeType := ntUnknown;
  end;
  inherited;
end;

procedure TXMLTree.DoGetText(ANode: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var Text: string);
var
  S  : UTF8String;
  ND : PNodeData;
begin
  //Logger.EnterMethod(Self, 'DoGetText');
  //Logger.Send('States', SetToString(TypeInfo(ANode.States), ANode.States));
  S := '';
  { TODO -oTS : Not sure why we get here when the component is destroyed. }
  if csDestroying in ComponentState then
    Exit;
  ND := GetData(ANode);
  if Assigned(ND) and Assigned(ND.XMLNode) then
  begin
    if Column = Header.MainColumn then
    begin
      if ND.NodeType = ntComment then
      begin
        S := ND.XMLNode.Value;
        ANode.States := ANode.States + [vsHeightMeasured];
      end
      else
      begin
        S := ND.XMLNode.Name;
        //if (ND.XMLNode.ElementType in [xeElement, xeDocType, xeInstruction])
        //  and not Expanded[ANode] then
        //begin
        //  N := ANode.FirstChild;
        //  while Assigned(N) do
        //  begin
        //    with GetData(N)^ do
        //      if NodeType <> ntAttribute then
        //        Break
        //      else
        //        S := S + ' ' + XMLNode.Value;
        //      N := N.NextSibling;
        //  end;
        //  ANode.States := ANode.States - [vsHeightMeasured];
        //end
      end;
    end
    else if Column = FValueColumn then
    begin
      if (ND.NodeType <> ntComment)
        and (ND.XMLNode.NodeCount > 0)
        and (ND.NodeType = ntText) then
        S := ND.XMLNode.Value;
      if (ND.NodeType in [ntElement, ntAttribute, ntText])
        or not Assigned(ND.XMLNode.SelectNode('*')) then
        S := ND.XMLNode.Value;
      if ND.NodeType = ntComment then
      begin
        S := '';
        ANode.States := ANode.States + [vsHeightMeasured];
      end
      else
      begin
        S := ND.XMLNode.Value;
      end;
    end;
  end;
  Text := string(S);
  inherited;
end;

procedure TXMLTree.DoCanEdit(ANode: PVirtualNode; Column: TColumnIndex;
  var Allowed: Boolean);
begin
  if Allowed and (Column in [FValueColumn, Header.MainColumn]) then
  begin
    case GetNodeType(ANode) of
      ntElement, ntAttribute, ntText:
        Allowed := Column = FValueColumn;
      ntComment:
        Allowed := Column = Header.MainColumn;
      else
        Allowed := False;
    end;
  end;
  inherited;
end;

procedure TXMLTree.DoNewText(ANode: PVirtualNode; Column: TColumnIndex;
  {$IFDEF FPC}const{$ENDIF} Text: string);
var
  ND : PNodeData;
begin
  inherited;
  ND := GetData(ANode);
  if (Column = FValueColumn)
    and (ND.NodeType in [ntElement, ntAttribute, ntText, ntNode])
    and (ND.XMLNode.Value <> UTF8String(Text)) then
  begin
    ND.XMLNode.Value := Text;
  end;
  //if ((Column = Header.MainColumn)
  //  and (ND.NodeType = ntComment) or (Column = FValueColumn)
  //  and ()
  //  and (ND.XMLNode.Value <> UTF8String(Text)) then
  //  begin
  //    ;
              //Logger.Send('Text', Text);
              //WriteToString =  Text;
//      if (NodeType <> ntComment) and (Text = '') then
//        with XMLNode do
//          while Assigned(FirstChild) do
//            RemoveChild(FirstChild);
//      if not(vsExpanded in ANode.States) then
//        ResetNode(ANode)
//      else
//        try
//          BeginUpdate;
//          ResetNode(ANode);
//          Expanded[ANode] := True;
//        finally
//          EndUpdate;
//        end;
//            end;
end;

function TXMLTree.DoCreateEditor(Node: PVirtualNode; Column: TColumnIndex)
  : IVTEditLink;
begin
  Result := TXMLEditLink.Create;
end;

function TXMLTree.DoGetNodeHint(ANode: PVirtualNode; Column: TColumnIndex;
  var LineBreakStyle: TVTTooltipLineBreakStyle): string;
begin
  if Column = Header.MainColumn then
    Result := GetData(ANode).XMLPath
  else
    Result := string(GetData(ANode).XMLNode.ElementTypeName);
  if Assigned(OnGetHint) then
    OnGetHint(Self, ANode, Column, LineBreakStyle, Result);
end;

function TXMLTree.DoGetImageIndex(ANode: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var Index: Integer)
  : TCustomImageList;
begin
  if (Column = Header.MainColumn) and (Kind in [ikNormal, ikSelected]) then
    Index := Ord(GetData(ANode).NodeType);
  Result := inherited DoGetImageIndex(ANode, Kind, Column, Ghosted, Index);
end;

procedure TXMLTree.KeyDown(var Key: Word; Shift: TShiftState);
var
  M : TMessage;
begin
  inherited KeyDown(Key, Shift);
  if not(tsEditing in TreeStates) and (Shift = []) and (Key in VK_EDIT_KEYS)
  then
  begin
    {$IFDEF WINDOWS}
    SendMessage(Self.Handle, WM_STARTEDITING, NativeUint(FocusedNode), 0);
    {$ENDIF}
    M.Result := 0;
    M.msg    := WM_KEYDOWN;
    M.WParam := Key;
    M.lParam := 0;
    EditLink.ProcessMessage(M);
  end;
end;

{$REGION 'Painting overrides' /autofold}
{ Some information taken from the Virtual Treeview manual:

  Usually the following paint stages are executed during a paint cycle:
  1.  before paint      (DoBeforePaint)
  2.  before item paint (DoBeforeItemPaint)
  3.  before item erase (DoBeforeItemErase)
  4.  after item erase  (DoAfterItemErase)
  5.  before cell draw  (DoBeforeCellPaint)
  6.  on paint text     (DoPaintText)
  7   text drawing      (DoTextDrawing)
  8.  after cell draw   (DoAfterCellPaint)
  9.  after item paint  (DoAfterItemPaint)
  10. after paint       (DoAfterPaint)
}

{$REGION 'documentation'}
{ This stage is entered once per node to be drawn and allows directly to control
  the path which is the taken to paint the node. (2)

  In the event for this stage you can tell the tree whether you want to paint
  the node entirely on your own or let the tree paint it. As this happens on a
  per node basis it is the perfect place to maintain a special layout without
  doing everything in the paint cycle. Note: setting the CustomDraw parameter
  in the event to True will skip the node entirely, without painting anything
  of the standard things like tree lines, button, images or erasing the
  background. Hence to display any useful information for the node do it in the
  OnBeforeItemPaint event.
  This is the first stage which gets the double buffer canvas which is used to
  draw a node so if you want to set special properties this is a good
  opportunity. Keep in mind though that in particular the colors are set by the
  tree according to specific rules (focus, selection etc.).
}
{$ENDREGION}

function TXMLTree.DoBeforeItemPaint(Canvas: TCanvas; Node: PVirtualNode;
  {$IFDEF FPC}const {$ENDIF} ItemRect: TRect): Boolean;
begin
  Result := inherited DoBeforeItemPaint(Canvas, Node, ItemRect);
end;

{$REGION 'documentation'}
{ This stage is also entered only once per node and allows to customize the
  node's background. (3)

  This stage and its associated event is usually used to give the node a
  different background color or erase the background with a special pattern
  which is different to what the tree would draw.
}
{$ENDREGION}

procedure TXMLTree.DoBeforeItemErase(Canvas: TCanvas; ANode: PVirtualNode;
{$IFDEF FPC}const{$ENDIF} ItemRect: TRect; var Color: TColor;
  var EraseAction: TItemEraseAction);
begin
  inherited DoBeforeItemErase(Canvas, ANode, ItemRect, Color, EraseAction);
end;

procedure TXMLTree.DoAfterItemErase(Canvas: TCanvas; Node: PVirtualNode;
  {$IFDEF FPC}const {$ENDIF}ItemRect: TRect);
begin
  inherited;

end;

{$REGION 'documentation'}
{ This paint stage is the first of the cell specific stages used to customize
  a single cell of a node and is called several times per node,depending on the
  number of columns. If no columns are used then it is called once.

  While internally a full setup for this node happened before the stage is
  entered (if it is the first run) the only noticeable effect for the
  application which has changed compared to after item erase is that the
  painting is limited to the current column. There are still no lines or images
  painted yet.
}
{$ENDREGION}

procedure TXMLTree.DoBeforeCellPaint(Canvas: TCanvas; ANode: PVirtualNode;
  Column: TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect;
  var ContentRect: TRect);
var
  C   : TColor;
  Ind : Integer;
begin
  C := clNone;
  if Column = Header.MainColumn then
  begin
    Ind := GetNodeLevel(ANode) * Indent;
    Inc(CellRect.Left, Ind);
    Ind := -Integer(Indent);
  end
  else
  begin
    Ind := 0;
  end;
  DoGetBackColor(ANode, Column, C);
  if C <> Color then
  begin // fill cell
    Canvas.Brush.Color := C;
    Canvas.FillRect(CellRect);
  end;

  if Column = Header.MainColumn then
  begin
    CellRect.Right := CellRect.Left + Integer(Indent);
    Inc(CellRect.Bottom);
    repeat
      if C <> Color then
      begin // fill vertical band
        Canvas.Brush.Color := C;
        Canvas.FillRect(CellRect);
      end;
      ANode := ANode.Parent;
      if not Assigned(ANode) or (ANode = RootNode) then
        Break;
      Inc(CellRect.Left, Ind);
      Inc(CellRect.Right, Ind);
      DoGetBackColor(ANode, Column, C);
    until False;
  end;
  inherited;
end;

{$REGION 'documentation'}
{ After default stuff like lines and images have been painted the paint node/
  paint text stage is entered.

  Because Virtual Treeview does not know how to draw the content of a node it
  delegates this drawing to a virtual method called DoPaintNode. Descendants
  override this method and do whatever is appropriate. For instance
  TVirtualDrawTree simply triggers its OnDrawNode event while the
  TVirtualStringTree prepares the target canvas and allows the application to
  override some or all canvas settings (font etc.) by triggering OnPaintText.
  After this event returned the text/caption of the node is drawn. Changed font
  properties are taken into account when aligning and painting the text.
  Note: The string tree triggers the OnGetText event two times if
  toShowStaticText is enabled in the TreeOptions.StringOptions property. Once
  for the normal text and once for the static text. Use the event's parameter to
  find out what is required.
}
{$ENDREGION}

procedure TXMLTree.DoPaintText(ANode: PVirtualNode; const Canvas: TCanvas;
  Column: TColumnIndex; TextType: TVSTTextType);
var
  NAI : TNodeAttributesItem;
begin

  NAI := FNodeAttributes.ItemByType[GetNodeType(ANode)];
  if Assigned(NAI) then
  begin
    if Column = 0 then
      Canvas.Font.Assign(NAI.Font)
    else
      Canvas.Font.Assign(NAI.ValueFont);
  end;
  inherited;
end;

procedure TXMLTree.DoTextDrawing(var PaintInfo: TVTPaintInfo; {$IFDEF FPC}const {$ENDIF}Text: string;
  CellRect: TRect; DrawFormat: Cardinal);
// var
// r: TRect;
begin
  inherited;
  // r := PaintInfo.CellRect;
  // r.Width := ClientWidth;
  //
  // PaintInfo.PaintOptions := PaintInfo.PaintOptions + [poMainOnly];
  // PaintInfo.PaintOptions := PaintInfo.PaintOptions - [poGridLines];
  // Windows.DrawTextW(PaintInfo.Canvas.Handle, PWideChar(Text), Length(Text), r, DT_CENTER or DT_VCENTER);
  // DefaultDraw := False;
end;

procedure TXMLTree.DoAfterCellPaint(Canvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; {$IFDEF FPC}const {$ENDIF}CellRect: TRect);
begin
  if (Node = FocusedNode) and (Column = FocusedColumn)  then
  begin
    Canvas.Brush.Color := clBlack;
    Canvas.FrameRect(CellRect);
    Canvas.Font.Color := clWhite;
  end;
  inherited;
end;

procedure TXMLTree.DoAfterItemPaint(Canvas: TCanvas; Node: PVirtualNode;
  {$IFDEF FPC}const {$ENDIF}ItemRect: TRect);
begin
  inherited;
end;

procedure TXMLTree.DoAfterPaint(Canvas: TCanvas);
begin
  inherited;
end;

procedure TXMLTree.DoGetBackColor(ANode: PVirtualNode; AColumn: TColumnIndex;
  var ABackColor: TColor);
var
  ND  : PNodeData;
  NAI : TNodeAttributesItem;
begin
  ND  := GetData(ANode);
  NAI := FNodeAttributes.ItemByType[ND.NodeType];
  if Assigned(NAI) then
  begin
    if AColumn = 0 then
      ABackColor := NAI.BackGroundColor
    else
      ABackColor := NAI.ValueBackGroundColor;
  end;
  if Assigned(FOnGetBackColor) then
    FOnGetBackColor(Self, ANode, ND.XMLNode, ND.NodeType, ABackColor);
end;
{$ENDREGION}
{$ENDREGION}

{$REGION 'private methods'}
procedure TXMLTree.WMChar(var Message: TWMChar);
begin
  with Message do
    if (CharCode in [Ord(^H), 32..255] -
        [VK_HOME, VK_END, VK_PRIOR, VK_NEXT, VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_BACK, VK_TAB,
         VK_ADD, VK_SUBTRACT, VK_MULTIPLY, VK_DIVIDE, VK_ESCAPE, VK_SPACE, Ord('+'), Ord('-'), Ord('*'), Ord('/')])
        and not Assigned(EditLink) then
      if Assigned(FocusedNode) and EditNode(FocusedNode, FocusedColumn) and Assigned(EditLink) then
      begin
//        EditLink.ProcessMessage(TMessage(Message));
        Message.CharCode := 0;
      end;
  inherited;
end;

procedure TXMLTree.IterateCallback(ASender: TBaseVirtualTree;
        ANode: PVirtualNode; AData: Pointer; var AAbort: Boolean);
begin
  if not(vsExpanded in ANode.States) then
    TStrings(AData).Add(GetData(ANode).XMLPath);
end;

{
  Explanation of the CheckNode event:

  This event is called for every Xml node in the document including text and
  other special node types.
  The Add parameter defines if the node will be displayed in the tree. It
  defaults to true on normal nodes, attributes and comments.

  You can set NewXmlNode to another node to display it instead. In this
  case you can also change NewNodeType accordingly. Or you set it to -1, then
  the NewNodeType and the Add flag is determined again and the event is also
  called again with the changed node.

  Note: Since the new tree node is not created in this state you cannot access
  it or set any user data. Use the InitNode event instead, it is called after
  the internal node initialization.
}

function TXMLTree.AddChild(ANode: PVirtualNode; ANewXMLNode: TXmlNode): Boolean;
var
  B  : Boolean;
  NT : TNodeType;
begin
  Result := False;
  repeat
    B := ANewXMLNode.ElementType in [xeElement, xeAttribute, xeComment];
    NT := GetDefaultNodeType(ANewXMLNode);
    DoCheckNode(ANode, ANewXMLNode, NT, B);
    if not(B and Assigned(ANewXMLNode)) then
      Exit;
  until NT <> ntUnknown;

  ChildCount[ANode] := ChildCount[ANode] + 1;
  with GetData(ANode.LastChild)^ do
  begin
    XMLNode := ANewXMLNode;
    NodeType := NT;
    XMLPath := GetXmlPath(XMLNode);
  end;
  Include(ANode.LastChild.States, vsInitialized);
  Result := True;
end;

function TXMLTree.AddChildren(ANode: PVirtualNode; AXMLNode: TXmlNode)
  : Cardinal;
var
  ParentPath : string;
  I          : Integer;
begin
  Result := 0;
  if Assigned(AXMLNode) and (AXMLNode.ElementType in [xeElement, xeAttribute]) then
  begin
    try
      BeginUpdate;
      if not Assigned(ANode) then
      begin
        ANode      := RootNode;
        ParentPath := '';
      end
      else
        ParentPath := GetData(ANode).XMLPath + '/';
      if AXMLNode.NodeCount > 0 then
      begin
        for I := 0 to AXMLNode.NodeCount - 1 do
          if AddChild(ANode, AXMLNode.Nodes[I]) then
            Inc(Result);
      end;
    finally
      EndUpdate;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'protected methods'}
procedure TXMLTree.InitializeNodeAttributes;
var
  NAI: TNodeAttributesItem;
begin
  NAI                 := FNodeAttributes.Add;
  NAI.Name            := 'Attribute';
  NAI.NodeType        := ntAttribute;
  NAI.BackGroundColor := DEFAULT_BGCOLOR_ATTRIBUTE;
  NAI.Font.Name       := 'Consolas';
  NAI.Font.Color      := DEFAULT_FGCOLOR_ATTRIBUTE;

  NAI                 := FNodeAttributes.Add;
  NAI.Name            := 'Comment';
  NAI.NodeType        := ntComment;
  NAI.BackGroundColor := DEFAULT_BGCOLOR_COMMENT;
  NAI.Font.Name       := 'Consolas';
  NAI.Font.Style      := [fsItalic];
  NAI.Font.Color      := DEFAULT_FGCOLOR_COMMENT;

  NAI                 := FNodeAttributes.Add;
  NAI.Name            := 'Element';
  NAI.NodeType        := ntElement;
  NAI.BackGroundColor := DEFAULT_BGCOLOR_ELEMENT;
  NAI.Font.Name       := 'Consolas';
  NAI.Font.Color      := DEFAULT_FGCOLOR_ELEMENT;

  NAI                 := FNodeAttributes.Add;
  NAI.Name            := 'Unknown';
  NAI.NodeType        := ntUnknown;
  NAI.BackGroundColor := DEFAULT_BGCOLOR_UNKNOWN;
  NAI.Font.Name       := 'Consolas';
  NAI.Font.Color      := DEFAULT_FGCOLOR_UNKNOWN;

  NAI                 := FNodeAttributes.Add;
  NAI.Name            := 'Root';
  NAI.NodeType        := ntRoot;
  NAI.BackGroundColor := DEFAULT_BGCOLOR_ROOT;
  NAI.Font.Name       := 'Consolas';
  NAI.Font.Color      := DEFAULT_FGCOLOR_ROOT;

  NAI                 := FNodeAttributes.Add;
  NAI.Name            := 'Text';
  NAI.NodeType        := ntText;
  NAI.BackGroundColor := DEFAULT_BGCOLOR_TEXT;
  NAI.Font.Name       := 'Consolas';
  NAI.Font.Color      := DEFAULT_FGCOLOR_TEXT;

  NAI                 := FNodeAttributes.Add;
  NAI.Name            := 'Node';
  NAI.NodeType        := ntNode;
  NAI.BackGroundColor := DEFAULT_BGCOLOR_NODE;
  NAI.Font.Name       := 'Consolas';
  NAI.Font.Style      := NAI.Font.Style + [fsBold];
  NAI.Font.Color      := DEFAULT_FGCOLOR_NODE;
end;

procedure TXMLTree.InitializeHeader;
begin
  if FValueColumn = 0 then
  begin
    with Header.Columns.Add do
    begin
      Text    := 'Node';
      Width   := 400;
      Options := Options + [coResizable, coSmartResize];
    end;
    with Header.Columns.Add do
    begin
      Text     := 'Value';
      Width    := 150;
      MaxWidth := 800;
      MinWidth := 50;
      Options  := Options + [coResizable, coSmartResize];
    end;
    Header.AutoSizeIndex := 0;
  end;
  FValueColumn := 1;
end;
{$ENDREGION}

{$REGION 'public methods'}
procedure TXMLTree.Clear;
begin
  BeginUpdate;
  inherited;
  FXMLDocument.Clear;
  EndUpdate;
end;

procedure TXMLTree.ExpandedStateClear;
begin
  with FExpandedState do
  begin
    List.Clear;
    InUse    := False;
    TopPath  := '';
    FocPath  := '';
    TopFound := nil;
    FocFound := nil;
  end;
end;

procedure TXMLTree.ExpandedStateSave;
begin
  with FExpandedState do
  begin
    ExpandedStateClear;
    if XMLDocument.IsEmpty then
      Exit;
    InUse := True;
    if Assigned(TopNode) then
      TopPath := GetData(TopNode).XMLPath;
    if Assigned(FocusedNode) then
      FocPath := GetData(FocusedNode).XMLPath;
    IterateSubtree(nil, IterateCallback, List,
      [vsInitialized, vsHasChildren, vsVisible]);
  end;
end;

{ Sets the expanded state of all nodes to the previously saved state. The nodes
  are searched by their XmlPath so that it works after a complete reload of the
  Xml. All new nodes are automatically expanded. }

procedure TXMLTree.ExpandedStateRestore;

  procedure Recurse(ANode: PVirtualNode);
  begin
    Expanded[ANode] := True;
    ANode           := ANode.FirstChild;
    while Assigned(ANode) do
    begin
      ValidateNode(ANode, False);
      with GetData(ANode)^, FExpandedState do
      begin
        if XMLPath = TopPath then
          TopFound := ANode;
        if XMLPath = FocPath then
          FocFound := ANode;
        if vsHasChildren in ANode.States then
          if List.IndexOf(XMLPath) < 0 then
            Recurse(ANode);
      end;
      ANode := ANode.NextSibling;
    end;
  end;

begin
  with FExpandedState do
  begin
    if not InUse then
      Exit;
    List.Sorted := True;
    Recurse(RootNode);
    TopNode            := TopFound;
    FocusedNode        := FocFound;
    Selected[FocFound] := True;
    ExpandedStateClear;
  end;
end;

function TXMLTree.GetData(ANode: PVirtualNode): PNodeData;
begin
  Result := PNodeData(GetNodeData(ANode));
end;

function TXMLTree.GetXMLNode(ANode: PVirtualNode): TXmlNode;
begin
  if Assigned(ANode) then
    Result := GetData(ANode).XMLNode
  else
    Result := nil;
end;

function TXMLTree.GetNodeType(ANode: PVirtualNode): TNodeType;
begin
  if Assigned(ANode) then
    Result := GetData(ANode).NodeType
  else
    Result := ntUnknown;
end;

function TXMLTree.GetElementType(ANode: PVirtualNode): TsdElementType;
begin
  if Assigned(ANode) then
    Result := GetData(ANode).XMLNode.ElementType
  else
    Result := xeError;
end;

function TXMLTree.GetDefaultNodeType(AXMLNode: TXmlNode): TNodeType;
begin
  case AXMLNode.ElementType of
    xeElement:
      if AXMLNode.Parent.ElementType = xeDocType then
        Result := ntRoot
      else if Assigned(AXMLNode.SelectNode('*')) then
        Result := ntNode
      else
        Result := ntElement;
    xeAttribute:
      Result := ntAttribute;
    xeComment:
      Result := ntComment;
    xeQuotedText, xeCData, xeWhiteSpace:
      Result := ntText;
    xeDocType, xeInstruction:
      Result := ntRoot;
    else
      Result := ntUnknown;
  end;
end;

procedure TXMLTree.RefreshNode(ANode: PVirtualNode; AParent: Boolean = False);
begin
  ExpandedStateSave;
  if AParent and Assigned(ANode.Parent) and (ANode.Parent <> RootNode) then
    ANode := ANode.Parent;
  BeginUpdate;
  try
    ResetNode(ANode);
    ExpandedStateRestore;
  finally
    ExpandedStateClear;
    EndUpdate;
  end;
end;

{ Note: XmlNode is not the new node to be added (see below)! }

procedure TXMLTree.NewNode(ANode: PVirtualNode; ANewNodeType: TNodeType;
  AValue: string = ''; AName: string = ''; ABefore: Boolean = False;
  AAddBreak: Boolean = False; AXmlNode: TXmlNode = nil);
var
  N : TXmlNode;
begin
  if not Assigned(ANode) then
    AXmlNode := GetXMLNode(FocusedNode);

  if not Assigned(AXmlNode) then
    AXmlNode := GetXMLNode(ANode);

  if ANewNodeType = ntAttribute then
  begin
    ABefore   := False;
    AAddBreak := False;
  end
  else if ANewNodeType = ntNode then
  begin
    ANewNodeType := ntElement;
  end;

  case ANewNodeType of
    ntAttribute:
    begin
      (AXMLNode as TsdAttribute).Name  := UTF8String(AName);
      (AXMLNode as TsdAttribute).Value := UTF8String(AValue);
    end;
    ntElement:
    begin
      N :=  XMLDocument.NodeNewTextType(AName, AValue, xeElement);
      //AXmlNode.NodeAdd(N);
      AXmlNode.NodeAdd(N);
      //Parent.NodeNew(AName).Value := AValue;
        //N := AXmlNode.Document.NodeNewType(Name, xeElement);
        //if Value <> '' then
        //  N.Value := Value;
        //if ABefore then
        //  Parent.NodeInsert(N, AXMLNode);
        //else
        //  Parent.NodeAdd(AXMLNode);
          //AppendChild(N);
    end;
    ntComment:
    begin
    //if Before then
          //ParentNode.InsertBefore(OwnerDocument.CreateComment(Value), AXMLNode)
        //else
          //AppendChild(Document.NodeNewType(Value, xeComment));
      N :=  XMLDocument.NodeNewType(AValue, xeComment);
      //AXmlNode.NodeAdd(N);
      AXmlNode.NodeAdd(N);
    end;
    ntText:
    begin
      N :=  XMLDocument.NodeNewType(AValue, xeQuotedText);
      //AXmlNode.NodeAdd(N);
      AXmlNode.NodeAdd(N);
    end;
  end;
//    if AAddBreak then
//      if Before then
//        ParentNode.InsertBefore(OwnerDocument.CreateTextNode(#13#10), AXMLNode)
//      else
//        AppendChild(OwnerDocument.CreateTextNode(#13#10));

  if not ABefore then
    Expanded[ANode] := True;
  RefreshNode(ANode, True);
end;

procedure TXMLTree.DeleteNode(Node: PVirtualNode; Reindex: Boolean);
begin
  GetXMLNode(Node).Delete;
  inherited;
end;

{ Calculates the path to the given xml node. }

function TXMLTree.GetXmlPath(AXMLNode: TXmlNode): string;
var
  S     : UTF8String;
  R     : UTF8String;
  Count : Integer;
  N     : TXmlNode;
begin
  if AXMLNode.ElementType = xeAttribute then
  begin
    R := '@' + AXMLNode.Name;
    AXMLNode := AXMLNode.SelectNode('..');
  end
  else
    R := '';
  while Assigned(AXMLNode) and (AXMLNode.ElementType <> xeDocType) do
  begin
    S := AXMLNode.Name;
    if AXMLNode.IndexInParent > 0 then
      N := AXMLNode.Parent.Nodes[AXMLNode.IndexInParent - 1]
    else
      N := nil;
    Count := 0;
    while Assigned(N) do
    begin
      if (N.ElementType = xeElement) and (N.Name = S) then
        Inc(Count);
      if N.IndexInParent > 0 then
        N := N.Parent.Nodes[N.IndexInParent - 1]
      else
        N := nil;
    end;
    if Count > 0 then
      S := S + '[' + UTF8String(IntToStr(Count)) + ']';
    if R = '' then
      R := S
    else
      R := S + '/' + R;
    AXMLNode := AXMLNode.Parent;
  end;
  Result := string(R);
end;

{ Finds a tree node by the given xml QueryString or path. }

function TXMLTree.FindNode(const AXPath: string; ADoInit: Boolean = False;
  ADoExpand: Boolean = False): PVirtualNode;
var
  N: TXmlNode;
begin
  Result := nil;
  N := XMLDocument.Root.SelectNode(AXPath);
  if Assigned(N) then
    Result := FindNode(N, ADoInit, ADoExpand);
end;

{ Finds a tree node by the given xml node. }

function TXMLTree.FindNode(AXMLNode: TXmlNode; ADoInit: Boolean = False;
  ADoExpand: Boolean = False): PVirtualNode;
var
  P : string;
  S : string;
  I : Integer;
begin
  P := GetXmlPath(AXMLNode);
  I := 0;
  Result := RootNode.FirstChild;
  try
    if ADoExpand then
      BeginUpdate;
    while Assigned(Result) do
    begin
      repeat
        Inc(I);
      until (I > Length(P)) or (P[I] = '/');
      S := Copy(P, 1, I - 1);

      while Assigned(Result) do
      begin
        if not(vsInitialized in Result.States) then
          if ADoInit or ADoExpand then
            ValidateNode(Result, False)
          else
          begin
            Result := nil;
            Exit;
          end;

        if GetData(Result).XMLPath = S then
        begin
          if I > Length(P) then
            Exit;

          if not Expanded[Result] then
            if ADoExpand then
              Expanded[Result] := True
            else if not ADoInit then
            begin
              Result := nil;
              Exit;
            end;
          Result := Result.FirstChild;
          Break;
        end
        else
          Result := Result.NextSibling;
      end;
    end;
  finally
    if ADoExpand then
      EndUpdate;
  end;
end;
{$ENDREGION}

{$REGION 'TExpandedState'}
procedure TExpandedState.AfterConstruction;
begin
  inherited;
  FList := TStringList.Create;
end;

procedure TExpandedState.BeforeDestruction;
begin
  FList.Free;
  inherited;
end;
{$ENDREGION}

end.
