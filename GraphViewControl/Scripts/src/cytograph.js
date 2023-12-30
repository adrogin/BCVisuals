import cytoscape from "cytoscape";
import popper from 'cytoscape-popper';
import edgehandles from "cytoscape-edgehandles";
import tippy from "tippy.js";
import contextMenus from "cytoscape-context-menus";
import { initializeContextMenu } from "./cycontextmenu.js";

cytoscape.use(popper);
cytoscape.use(edgehandles);
cytoscape.use(contextMenus);

var cy;  // Global Cytoscape instance
var eh;  // EdgeHandles instance

function renderGraph(containerElement, nodes, edges, styles, onClickEventCallback) {
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

  cy.nodes().bind("click", onClickEventCallback);
}

function renderGraphWithNavExtensibilityBinding(containerElement, nodes, edges, styles) {
  renderGraph(
    containerElement, nodes, edges, styles,
    (event) => {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnNodeClick', [event.target.id()])
    });
}

function getDefaultElementStyles() {
  return [
    {
      selector: 'node',
      css: {
        'background-color':'#61bffc',
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
        data: node
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

function addNodes(cy, nodeData) {
  var nodes = [];

  nodeData.forEach(node => {
    nodes.push(
      {
        data: node
      });
  });

  cy.add({ group: 'nodes', nodes });
}

function addEdges(cy, edges) {
  edges.forEach(edge => {
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

function setGraphLayout(layoutName) {
  var layout = cy.layout({name: layoutName});
  layout.run();
}

function createNodePopper(nodeIndex, popperContent) {
  let node = cy.nodes()[nodeIndex];
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
  });

  createTooltips();
}

function initEdgeHandles() {
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
  renderGraphWithNavExtensibilityBinding,
  addNodes,
  addEdges,
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
