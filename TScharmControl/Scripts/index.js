function CreateChart (Width, Height) {
    tscharmControl.createChart(Width, Height);
}

function AddNewLine() {
    tscharmControl.addNewLine();
}

function RemoveLine(Index) {
    tscharmControl.remove(Index);
}

function SetLineLabel(Index, Label) {
    tscharmControl.SetLineLabel(Index, Label);
}

function SetAllLineLabels(Labels) {
    tscharmControl.setLabels(Labels);
}

function AddBar(LineIndex, Position, Width, ClassName) {
    tscharmControl.addBar(LineIndex, Position, Width, ClassName);
}

function RemoveBar(LineIndex, BarIndex) {
    tscharmControl.removeBar(LineIndex, BarIndex);
}

function Draw() {
    tscharmControl.draw();
}

function Clear() {
    tscharmControl.clear();
}

function RequestDocumentSize() {
    tscharmControl.requestDocumentSize();
}

function SendDocumentSize(Width, Height) {
    tscharmControl.sendDocumentSize(Width, Height);
}

function ShowLabels(Show) {
    tscharmControl.showLabels(Show);
}

function SetXAxisMarks(Marks) {
    tscharmControl.setXAxisMarks(Marks);
}

function SetScale(MinValue, MaxValue) {
    tscharmControl.setScale(MinValue, MaxValue);
}

function BindBarEvents() {
    tscharmControl.bindBarEvents();
}

function SetAllowOverlap(IsAllowed) {
    tscharmControl.setAllowOverlap(IsAllowed);
}