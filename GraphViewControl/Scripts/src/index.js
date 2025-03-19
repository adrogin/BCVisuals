import {
    renderGraph, setGraphLayout, setNodeTooltipText, createTooltips, initEdgeHandles, setEditModeEnabled, initializeDefaultContextMenu, 
    destroyContextMenu, sendGraphElementsToNavExtensibilityCaller, setNodeTooltipsOnAllNodes, addNodes, addEdges, removeNodes, removeEdges, setNodeData,
    setNodeLabel, pushNodeData
} from "./cytograph.js";

/**
 * Create and render the graph object with default styles.
 * @param {String} containerElementName - The name of the HTML element where the graph will embedded. For Business Central controls this should be "controlAddIn".
 * @param {Object[]} nodes - Array of Node elements.
 * @param {Object[]} edges - Array of Edge elements.
 */
export function DrawGraph(containerElementName, nodes, edges) {
    DrawGraphWithStyles(document.getElementById(containerElementName), nodes, edges, undefined);
};

/**
 * Create and render the graph object with custom node styles. Default style will be applied to all nodes not covered by provided selectors.
 * @param {String} containerElementName - The name of the HTML element where the graph will be embedded.
 * @param {Object[]} nodes - Array of Node elements.
 * @param {Object[]} edges - Array of Edge elements.
 * @param {Object[]} styles - Array of element styles with selectors.
 */
export function DrawGraphWithStyles(containerElementName, nodes, edges, styles) {
    renderGraph(
        document.getElementById(containerElementName), nodes, edges, styles,
        {
            onNodeClick: (event) => {
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnNodeClick', [event.target.id()])
                event.stopPropagation();  // To prevent the event from firing twice on compound nodes
            },
            onEdgeCreated: (event) => { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnEdgeCreated', [event.target.data()]) },
            onEdgeRemoved: (event) => { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnEdgeRemoved', [event.target.data()]) },
            onNodeCreated: (event) => { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnNodeCreated', [event.target.data()]) },
            onNodeRemoved: (event) => { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnNodeRemoved', [event.target.data()]) },
        }
    );
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
    setNodeTooltipsOnAllNodes(tooltips);
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
    initEdgeHandles(
        {
            onEdgeDrawingStart:
                (event, sourceNode) => { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnEdgeDrawingStart', [sourceNode.data()]) },
            onEdgeDrawingStop:
                (event, sourceNode) => { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnEdgeDrawingStop', [sourceNode.data()]) },
            onEdgeDrawingDone:
                (event, sourceNode, targetNode, addedEdge) => {
                    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnEdgeDrawingDone', [sourceNode.data(), targetNode.data(), addedEdge.data()])
                },
            onEdgeDrawingCanceled:
                (event, sourceNode, canceledTargets) => { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnEdgeDrawingCanceled', [sourceNode.data(), pushNodeData(canceledTargets)]) }
        });
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
    sendGraphElementsToNavExtensibilityCaller();
}

/**
 * Add nodes to the active graph instance
 * @param {Object[]} nodesToAdd - array of Node elements to be added to the graph 
 */
export function AddNodes(nodesToAdd) {
    addNodes(nodesToAdd);
}

/**
 * Add edges to the active graph instance
 * @param {Object[]} edgesToAdd - array of Edge elements to be added to the graph 
 */
export function AddEdges(edgesToAdd) {
    addEdges(edgesToAdd);
}

/**
 * Remove nodes from the active graph instance.
 * @param {Object[]} nodesToRemove - array of Node elements to be removed. Node objects must contain the id value, other properties are ignored.
 * If a node with the given id is not found in the graph, the array element is ignored.
 */
export function RemoveNodes(nodesToRemove) {
    removeNodes(nodesToRemove);
}

/**
 * Remove edges from the active graph instance.
 * @param {Object[]} edgesToRemove - array of Edge elements to be removed. Edge objects must contain the source and target values, other properties are ignored.
 * If a node with the given id is not found in the graph, the array element is ignored.
 * Edges being removed are filtered based on the source and target values. If the graph contains mmultiple nodes between the same source and target nodes, all parallel edges will be removed.
 */
export function RemoveEdges(edgesToRemove) {
    removeEdges(edgesToRemove);
}

/**
 * Update the data object associated with the specified node
 * @param {Text} nodeId - ID of the node to be updated
 * @param {Object} nodeData - Data object containing new node properties. Properties that are already defined in the node will be overwritten, new properties will be added. 
 */
export function SetNodeData(nodeId, nodeData) {
    setNodeData(nodeId, nodeData);
}

/**
 * Update the node label
 * @param {Text} nodeId - ID of the node being updated 
 * @param {Text} label - New label text
 */
export function SetNodeLabel(nodeId, label) {
    setNodeLabel(nodeId, label);
}
