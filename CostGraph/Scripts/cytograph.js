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

function setNodeTooltip(nodeIndex, popperContent) {
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
