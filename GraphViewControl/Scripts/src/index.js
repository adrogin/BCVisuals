import {
    renderGraph, setGraphLayout, setNodeTooltipText, bindTooltipEvents, createTooltips, initEdgeHandles, setEditModeEnabled, initializeDefaultContextMenu, 
    destroyContextMenu, sendGraphElementsToCaller
} from "./cytograph.js";

/**
 * Create and render the graph object with default styles.
 * @param {String} containerElementName - The name of the HTML element where the graph will embedded.
 * @param {Object[]} nodes - Array of Node elements.
 * @param {Object[]} edges - Array of Edge elements.
 */
export function DrawGraph(containerElementName, nodes, edges) {
    renderGraph(document.getElementById(containerElementName), nodes, edges);
};

/**
 * Create and render the graph object with custom node styles. Default style will be applied to all nodes not covered by provided selectors.
 * @param {String} containerElementName - The name of the HTML element where the graph will be embedded.
 * @param {Object[]} nodes - Array of Node elements.
 * @param {Object[]} edges - Array of Edge elements.
 * @param {Object[]} styles - Array of element styles with selectors.
 */
export function DrawGraphWithStyles(containerElementName, nodes, edges, styles) {
    renderGraph(document.getElementById(containerElementName), nodes, edges, styles);
};

/**
 * Set the graph layout
 * @param {String} layoutName - The name of the graph layout. Refer to https://js.cytoscape.org/#layouts for supported layouts.
 */
export function SetLayout(layoutName) {
    setGraphLayout(layoutName);
};

/**
 * Set the tooltip text on one node
 * @param {String} nodeId - ID of the node to apply the tooltip to
 * @param {String} tooltipText - Text of the tooltip
 */
export function SetNodeTooltipText(nodeId, tooltipText) {
    setNodeTooltipText(nodeId, tooltipText);
};

/**
 * Set toolip text on multiple nodes passed in an array
 * @param {Object[]} tooltips - Array of node identifiers with tooltip texts for each node.
 * Array must have the following structure: [ { "nodeId": "ID", "content": "Tooltip Text" } ]
 */
export function SetTooltipTextOnMultipleNodes(tooltips) {
    let index = 0;

    tooltips.forEach(tooltip => {
        SetNodeTooltipText(index++, tooltip.content);
    });
};

/**
 * Bind event listeners on nodes' "mouseover" and "mouseout" events to enable the tooltip functionality
 */
export function BindTooltipEvents() {
    bindTooltipEvents();
};

/**
 * Create tooltip elements on all nodes that have the tooltip text assigned.
 * Prior to calling CreateTooltips, tooltip text must be set on nodes by one of the functions - SetNodeTooltipText or SetTooltipTextOnMultipleNodes.
 */
export function CreateTooltips() {
    createTooltips();
};

/**
 * Initialize the EdgeHandles extension to allow editing edges
 */
export function InitializeEdgeHandles() {
    initEdgeHandles();
}

/**
 * Toggle the graph view between view and edit modes
 * @param {Boolean} isEditModeEnabled - Indicates whether the graph view must be in the edit mode (true) or view mode (false)
 */
export function SetEditModeEnabled(isEditModeEnabled) {
    setEditModeEnabled(isEditModeEnabled);
}

/**
 * Create an instance of the cytoscape context menu with default bindings and menu items.
 */
export function InitializeDefaultContextMenu() {
    initializeDefaultContextMenu();
}

/**
 * Destroy the instance of the context menu.
 */
export function DestroyContextMenu() {
    destroyContextMenu();
}

/**
 * This method invokes the callback method OnGraphDataReceived, passing the nodes and edges of the graph back to the caller.
 */
export function RequestGraphData() {
    sendGraphElementsToCaller();
}
