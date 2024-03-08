import cytoscape from "cytoscape";
import popper from 'cytoscape-popper';
import edgehandles from "cytoscape-edgehandles";
import tippy from "tippy.js";
import contextMenus from "cytoscape-context-menus";
import { initializeContextMenu } from "./cycontextmenu.js";

import '../../CSS/style.css';

cytoscape.use(popper);
cytoscape.use(edgehandles);
cytoscape.use(contextMenus);

var cy;  // Global Cytoscape instance
var eh;  // EdgeHandles instance

function renderGraph(containerElement, nodes, edges, styles, eventCallbacks) {
  if (cy != null) {
    cy.destroy();
  }

  const defaultStyles = getDefaultElementStyles();
  styles = styles === undefined ? defaultStyles : defaultStyles.concat(styles);

  cy = cytoscape({
    container: containerElement,

    elements: {
      nodes: formatNodes(nodes),
      edges: formatEdges(edges)
    },

    style: styles,

    layout: {
      name: 'breadthfirst'
    }
  });

  createTextElements(nodes);
  bindCytoscapeEventHandlers(eventCallbacks);
}

function bindCytoscapeEventHandlers(eventCallbacks) {
  if (eventCallbacks !== undefined) {
    cy.nodes().bind('click', eventCallbacks.onNodeClick);
    cy.bind('add', 'node', eventCallbacks.onNodeCreated);
    cy.bind('add', 'edge', eventCallbacks.onEdgeCreated);
    cy.bind('remove', 'node', eventCallbacks.onNodeRemoved);
    cy.bind('remove', 'edge', eventCallbacks.onEdgeRemoved);
  }
}

function getDefaultElementStyles() {
  return [
    {
      selector: 'node',
      css: {
        'background-color':'#61bffc',
      }
    },
    {
      selector: 'node[^label]',
      css: {
        'content': 'data(id)'
      }
    },
    {
      selector: 'edge',
      css: {
        'width': 2,
        'line-color': '#ccc',
        'target-arrow-color': '#ccc',
        'target-arrow-shape': 'triangle',
        'curve-style': 'bezier'
      }
    }
  ]
}

function formatNodes(nodeData) {
  var nodes = [];

  nodeData.forEach(node => {
    nodes.push(
      {
        data: stripNewLineEscaping(node)
      });
  });

  return nodes;
}

function formatEdges(edges) {
  var edgeObjects = [];

  edges.forEach(edge => {
    edgeObjects.push(
      {
        data: {
          id: edge.source + edge.target,
          source: edge.source,
          target: edge.target
        }
      });
  });

  return edgeObjects;
}

function addNodes(nodeData) {
  var nodes = [];

  nodeData.forEach(node => {
    nodes.push(
      {
        data: stripNewLineEscaping(node)
      });
  });

  cy.add({ group: 'nodes', nodes });
}

function addEdges(edgesData) {
  edgesData.forEach(edge => {
    cy.add(
      {
        group: 'edges',
        data: {
          id: edge.source + edge.target,
          source: edge.source,
          target: edge.target
      }
    });
  });
}

function removeNodes(nodesToRemove) {
  nodesToRemove.forEach(node => {
    cy.remove(`node[id="${node.id}"]`)
  });
}

function removeEdges(edgesToRemove) {
  edgesToRemove.forEach(edge => {
    cy.remove(`edge[source="${edge.source}"][target="${edge.target}"]`)
  });
}

function setGraphLayout(layoutName) {
  var layout = cy.layout({name: layoutName});
  layout.run();
}

function createNodePopper(nodeId, popperContent) {
  let node = cy.getElementById(nodeId);
  let popper = node.popper({
      content: () => {
          let div = document.createElement('div');
          div.innerHTML = popperContent;
          document.body.appendChild(div);
      
          return div;
        }
  });

  let update = () => {
    popper.update();
  };
  
  node.on('position', update);  
  cy.on('pan zoom resize', update);
}

function setNodeTooltipText(nodeId, tooltipText) {  
  cy.getElementById(nodeId).tooltipText = tooltipText;
}

function setNodeTooltipsOnAllNodes(tooltips) {
  let index = 0;

  tooltips.forEach(tooltip => {
      setNodeTooltipTextOnNodeIndex(index++, tooltip.content);
  });
}

function setNodeTooltipTextOnNodeIndex(nodeIndex, tooltipText) {  
  cy.nodes()[nodeIndex].tooltipText = tooltipText;
}

function createTooltips() {
  cy.nodes().forEach(node => {
    if (typeof node.tooltipText !== 'undefined')
      createNodeTooltip(node);
  });

  bindTooltipEvents();
}

function createNodeTooltip(node) {
  if (node.tooltipText == '') {
    return;
  }

  let ref = node.popperRef();
  let dummyDomElement = document.createElement("div");

  let tip = tippy(dummyDomElement, {
    getReferenceClientRect: ref.getBoundingClientRect,
    trigger: "manual",
    placement: "bottom",
    theme: "tippy",
    allowHTML: true,

    content: () => {
      let content = document.createElement("div");
      content.innerHTML = node.tooltipText;
      
      return content;
    }
  });

  node.tip = tip;
}

function bindTooltipEvents() {
  cy.nodes().unbind("mouseover");
  cy.nodes().bind("mouseover", event => {
    if (event.target.tip != null) {
      event.target.tip.show();
    }
  });

  cy.nodes().unbind("mouseout");
  cy.nodes().bind("mouseout", event => {
    if (event.target.tip != null) {
      event.target.tip.hide();
    }
  });
}

function createTextElements(nodeDefs) {
  nodeDefs.forEach(nodeDef => {
    if (typeof nodeDef.tooltip !== 'undefined')
      setNodeTooltipText(nodeDef.id, nodeDef.tooltip);

    if (typeof nodeDef.popper !== 'undefined')
      createNodePopper(nodeDef.id, nodeDef.popper);   
    });

  createTooltips();
}

function stripNewLineEscaping(node) {
  if (typeof node.label !== 'undefined') {
    node.label = node.label.replace('\\n', '\n');
  }

  return node;
}

function initEdgeHandles(eventCallbacks) {
  let defaults = {
    canConnect: function(sourceNode, targetNode){
      return !sourceNode.same(targetNode);
    },
    edgeParams: function(sourceNode, targetNode){
      return {};
    },
    hoverDelay: 150,
    snap: true,
    snapThreshold: 50,
    snapFrequency: 15,
    noEdgeEventsInDraw: true,
    disableBrowserGestures: true
  };
  
  eh = cy.edgehandles(defaults);
  bindEdgeHandlesEvents(eventCallbacks);
}

function bindEdgeHandlesEvents(eventCallbacks) {
  let onEdgeDrawingStartCallback = eventCallbacks != null && eventCallbacks.onEdgeDrawingStart !== undefined ?
    eventCallbacks.onEdgeDrawingStart :
    (event, sourceNode) => { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnEdgeDrawingStart', [sourceNode.data()]) };

  let onEdgeDrawingStopCallback = eventCallbacks != null && eventCallbacks.onEdgeDrawingStop !== undefined ?
    eventCallbacks.onEdgeDrawingStop :
    (event, sourceNode) => { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnEdgeDrawingStop', [sourceNode.data()]) };
  
  let onEdgeDrawingDoneCallback = eventCallbacks != null && eventCallbacks.onEdgeDrawingDone !== undefined ?
    eventCallbacks.onEdgeDrawingDone :
    (event, sourceNode, targetNode, addedEdge) => { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnEdgeDrawingDone', [sourceNode.data(), targetNode.data()]) };
  
  let onEdgeDrawingCanceledCallback = eventCallbacks != null && eventCallbacks.onEdgeDrawingCanceled !== undefined ?
    eventCallbacks.onEdgeDrawingCanceled :
    (event, sourceNode, canceledTargets) => { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnEdgeDrawingCanceled', [sourceNode.data(), pushNodeData(canceledTargets)]) };

  cy.on('ehstart', onEdgeDrawingStartCallback);
  cy.on('ehstop', onEdgeDrawingStopCallback);
  cy.on('ehcomplete', onEdgeDrawingDoneCallback);
  cy.on('ehcancel', onEdgeDrawingCanceledCallback);
}

function pushNodeData(nodes) {
  let nodeData = [];

  nodes.forEach(node => {
    nodeData.push(node.data());
  });

  return nodeData;
}

function setEditModeEnabled(isEnabled) {
  isEnabled ? eh.enableDrawMode() : eh.disableDrawMode();
}

function initializeDefaultContextMenu() {
  initializeContextMenu(cy);  
}

function destroyContextMenu() {
  cy.contextMenu.destroy();
}

function sendGraphElementsToCaller(eventCallback) {
  var nodes = [];
  var edges = [];
  
  if (cy != null) {
    cy.nodes().forEach(node => {
      nodes.push({id: node.data().id});
    });

    cy.edges().forEach(edge => {
      edges.push({ id: edge.data().id, source: edge.data().source, target: edge.data().target });
    });
  }

  eventCallback(nodes, edges);
}

function sendGraphElementsToNavExtensibilityCaller() {
  sendGraphElementsToCaller(
    (nodes, edges) => { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnGraphDataReceived', [nodes, edges]) }
  );
}

function getGraphElements() {
  return cy.elements();
}

export {
  renderGraph,
  addNodes,
  addEdges,
  removeNodes,
  removeEdges,
  setGraphLayout,
  createNodePopper,
  setNodeTooltipText,
  createTooltips,
  setNodeTooltipsOnAllNodes,
  initEdgeHandles,
  setEditModeEnabled,
  initializeDefaultContextMenu,
  destroyContextMenu,
  sendGraphElementsToCaller,
  sendGraphElementsToNavExtensibilityCaller,
  getGraphElements
}
