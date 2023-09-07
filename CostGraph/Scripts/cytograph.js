var cy;

function renderGraph(containerElement, nodes, edges) {
  if (cy != null) {
    cy.destroy();
  }
  
  cy = cytoscape({
    container: containerElement,

    elements: {
        nodes: formatNodes(nodes),
        edges: formatEdges(edges)
  	},

    style: [ 
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
    ],

    layout: {
      name: 'circle'
    }
  });
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

  console.log(nodes);

  return nodes;
}

function setGraphLayout(layoutName) {
  var layout = cy.layout({name: layoutName});
  layout.run();
}

function formatEdges(edges) {
  var edgeObjects = [];
  //var count = 1;

  edges.forEach(edge => {
    const key = Object.keys(edge)[0];
    edgeObjects.push(
      {
        data: {
          id: key + edge[key],
          source: key,
          target: edge[key]
        }
      });
  });

  console.log(edgeObjects);

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
  var count = 1;

  edges.forEach(edge => {
    const key = Object.keys(edge)[0];
    cy.add(
      {
        group: 'edges',
        data: {
          id: key + edge[key], source: key, target: edge[key]
      }
    });
  });
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
    console.log(node);
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
    theme: "light",

    content: () => {
      let content = document.createElement("div");
      content.innerHTML = node.tooltipText;

      return content;
    }
  });

  node.tip = tip;

  console.log(node);
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
