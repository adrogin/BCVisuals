function DrawGraph(containerElementName, nodes, edges) {
    renderGraph(document.getElementById(containerElementName), nodes, edges);
};

function SetLayout(layoutName) {
    setGraphLayout(layoutName);
};

function SetNodeTooltipText(nodeId, tooltipText) {
    setNodeTooltipText(nodeId, tooltipText);
};

function SetTooltipTextOnMultipleNodes(tooltips) {
    let index = 0;

    tooltips.forEach(tooltip => {
        SetNodeTooltipText(index++, tooltip.content);
    });
};

function BindTooltipEvents() {
    bindTooltipEvents();
};

function CreateTooltips() {
    createTooltips();
};
