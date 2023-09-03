function renderGraph(containerElement, nodes, edges) {
  var cy = cytoscape({
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

  console.log(cy);
}

function formatNodes(nodeIds) {
  var nodes = [];

  nodeIds.forEach(nodeId => {
    nodes.push({data: {id: nodeId}});
  });

  console.log(nodes);

  return nodes;
}

function formatEdges(edges) {
  var edgeObjects = [];
  //var count = 1;

  edges.forEach(edge => {
    const key = Object.keys(edge)[0];
    edgeObjects.push({ data: {id: key + edge[key], source: key, target: edge[key]} });
  });

  console.log(edgeObjects);

  return edgeObjects;
}

function addNodes(cy, nodeIds) {
  nodeIds.forEach(nodeId => {
    cy.add({group: 'nodes', data: {id: nodeId}});
  });
}

function addEdges(cy, edges) {
  var count = 1;

  edges.forEach(edge => {
    const key = Object.keys(edge)[0];
    cy.add({group: 'edges', data: {id: key + edge[key], source: key, target: edge[key]} });
  });
}
