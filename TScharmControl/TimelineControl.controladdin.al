controladdin "Timeline Control"
{
    RequestedHeight = 300;
    MinimumHeight = 300;
    RequestedWidth = 500;
    MinimumWidth = 500;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;

    Scripts =
        'dist/main.js',
        'Scripts/index.js';
    StartupScript = 'Scripts/startup.js';
    StyleSheets = 'dist/main.css';

    procedure CreateChart(Width: Integer; Height: Integer);
    procedure ShowLabels(Show: Boolean);
    procedure SetXAxisMarks(Marks: JsonArray);
    procedure AddNewLine();
    procedure RemoveLine(Index: Integer);
    procedure SetLineLabel(Index: Integer; Label: Text);
    procedure SetAllLineLabels(Labels: JsonArray);
    procedure AddBar(LineIndex: Integer; Position: Integer; Width: Integer; ClassName: Text);
    procedure AddBar(LineIndex: Integer; StartDateTime: DateTime; Duration: Integer; ClassName: Text);
    procedure RemoveBar(LineIndex: Integer; BarIndex: Integer);
    procedure BindBarEvents();
    procedure Draw();
    procedure Clear();
    procedure SetScale(MinValue: Integer; MaxValue: Integer);
    procedure SetScale(MinValue: DateTime; MaxValue: DateTime);
    procedure RequestDocumentSize();

    event ControlAddInReady();
    event OnResizeLeftDone(LineId: Integer; BarId: Integer; NewPosition: Integer);
    event OnResizeRightDone(LlineId: Integer; BarId: Integer; NewWidth: Integer);
    event OnDragDone(LineId: Integer; BarId: Integer; NewPosition: Integer);
    event OnDocumentSizeReceived(Width: Integer; Height: Integer);
}
