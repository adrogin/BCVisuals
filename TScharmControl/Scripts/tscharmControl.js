import { Chart, Slider } from "tscharm";
import "tscharm/stylesheets/chart.css";

var chart;
var slider;

export function createChart (Width, Height) {
    chart = new Chart(Width <= 0? null : Width, Height <= 0 ? null : Height);
    slider = new Slider(chart);
}

export function addNewLine() {
    chart.lines.addNew();
}

export function removeLine(Index) {
    chart.lines.remove(Index);
}

export function setLineLabel(Index, Label) {
    chart.lines.get(Index).label = Label;
}

export function setAllLineLabels(Labels) {
    chart.lines.setLabels(Labels);
}

export function addBar(LineIndex, Position, Width, ClassName) {
    const barPosition = typeof Position == "string" ? new Date(Position).getTime() : Position;
    chart.lines.get(LineIndex).bars.add(barPosition, Width, ClassName);
}

export function removeBar(LineIndex, BarIndex) {
    chart.lines.get(LineIndex).bars.remove(BarIndex);
}

export function draw() {
    chart.draw(document.getElementById('controlAddIn'));
}

export function clear() {
    chart.htmlElement.remove();
    chart = null;
}

export function requestDocumentSize() {
    SendDocumentSize(document.body.clientWidth, document.body.clientHeight);
}

export function sendDocumentSize(width, height) {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnDocumentSizeReceived', [width, height]);
}

export function showLabels(Show) {
    chart.showAxes = Show;
}

export function setXAxisMarks(Marks) {
    chart.xAxis.initializeMarker(Marks);
}

export function setScale(MinValue, MaxValue) {
    if (typeof MinValue === "string") {
        MinValue = new Date(MinValue);
        MaxValue = new Date(MaxValue);
    }
    chart.setScale(MinValue, MaxValue);
}

export function setAllowOverlap(isAllowed) {
    chart.lines.allowOverlap = isAllowed;
}

export function bindBarEvents() {
    chart.bindEventHandler(
        'onResizeLeftDone', (LineId, BarId, NewPosition) => Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnResizeLeftDone', [LineId, BarId, NewPosition]));
    chart.bindEventHandler(
        'onResizeRightDone', (LineId, BarId, NewWidth) => Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnResizeRightDone', [LineId, BarId, NewWidth]));
    chart.bindEventHandler(
        'onDragDone', (LineId, BarId, NewPosition) => Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnDragDone', [LineId, BarId, NewPosition]));
}
