var cy;

function renderGraph(containerElement, nodes, edges, styles) {
  if (cy != null) {
    cy.destroy();
  }

  styles = styles.concat(getDefaultElementStyles());

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

  cy.nodes().bind("click",
    (event) => {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnNodeClick', [event.target.id()]);
    }
  );
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

function formatNodes(nodeIds) {
  var nodes = [];

  nodeIds.forEach(nodeId => {
    nodes.push(
      {
        data: {
          id: nodeId
        }
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

function addNodes(cy, nodeIds) {
  nodeIds.forEach(nodeId => {
    cy.add(
      {
        group: 'nodes',
        data: {
          id: nodeId
        }
      });
  });
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
  cy.nodes()[nodeId].tooltipText = tooltipText;
}

function createTooltips() {
  cy.nodes().forEach(node => {
    createNodeTooltip(node);
  });
}

function createNodeTooltip(node) {
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

function CreateTextElements() {
  createTooltips();
  bindTooltipEvents();
}