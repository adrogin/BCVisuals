import { renderGraph, getGraphElements, setNodeTooltipText, setNodeTooltipsOnAllNodes, createTooltips, setGraphLayout,
    addNodes, addEdges, removeNodes, removeEdges
} from "../src/cytograph";

import 'jest-canvas-mock';

import {
    graphNodesFilter, graphEdgesFilter, getSampleGraphElementArrays, getSampleGraphElementArraysWithData, getSampleNodeTooltipsArray, 
    getSampleGraphElementArraysWithLabels, nodeIdFilter, edgeNodesFilter
} from "./testutils";

test('Build graph from nodes and edges arrays in format provided by BC', () => {
    const graphDefinition = getSampleGraphElementArrays();

    renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges); // Undefined container for headless Cytoscape instance
    
    let graphElements = getGraphElements();
    expect(graphElements.size()).toBe(5);

    let nodeElements = graphElements.filter(graphNodesFilter);
    let edgeElements = graphElements.filter(graphEdgesFilter);
    expect(nodeElements.size()).toBe(3);
    expect(edgeElements.size()).toBe(2);
    
    expect(nodeElements.filter(nodeIdFilter('A')).size()).toBe(1);
    expect(nodeElements.filter(nodeIdFilter('B')).size()).toBe(1);
    expect(nodeElements.filter(nodeIdFilter('C')).size()).toBe(1);

    expect(edgeElements.filter(edgeNodesFilter('A', 'B')).size()).toBe(1);
    expect(edgeElements.filter(edgeNodesFilter('A', 'C')).size()).toBe(1);
});

test('Graph nodes must not have tooltips if the initial dataset does not provide tooltip data', () => {
    const graphDefinition = getSampleGraphElementArrays();

    renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges);

    getGraphElements().filter(graphNodesFilter).forEach(node => {
        expect(node.tip).toBeUndefined();
        expect(node.tooltipText).toBeUndefined();
    });
});

test('Node tooltips must be initialized from the node dataset that contains tooltip info', () => {
    const graphDefinition = getSampleGraphElementArraysWithData();

    renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges);

    let nodeElements = getGraphElements().filter(graphNodesFilter);
    expect(nodeElements.filter(nodeIdFilter('A'))[0].tooltipText).toBe('TooltipA');
    expect(nodeElements.filter(nodeIdFilter('B'))[0].tooltipText).toBeUndefined();
    expect(nodeElements.filter(nodeIdFilter('C'))[0].tooltipText).toBe('TooltipC');

    expect(nodeElements.filter(nodeIdFilter('A'))[0].tip.popper._tippy.props.content.innerHTML).toContain('TooltipA');
    expect(nodeElements.filter(nodeIdFilter('B'))[0].tip).toBeUndefined();
    expect(nodeElements.filter(nodeIdFilter('C'))[0].tip.popper._tippy.props.content.innerHTML).toContain('TooltipC');
});

test('Tooltips can be set on nodes after creating a graph instance', () => {
    const graphDefinition = getSampleGraphElementArrays();

    renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges);
    setNodeTooltipsOnAllNodes(getSampleNodeTooltipsArray());

    let nodeElements = getGraphElements().filter(graphNodesFilter);
    expect(nodeElements.filter(nodeIdFilter('A'))[0].tooltipText).toBe('TooltipA');
    expect(nodeElements.filter(nodeIdFilter('B'))[0].tooltipText).toBe('TooltipB');
    expect(nodeElements.filter(nodeIdFilter('C'))[0].tooltipText).toBe('TooltipC');

    createTooltips();
    expect(nodeElements.filter(nodeIdFilter('A'))[0].tip.popper._tippy.props.content.innerHTML).toContain('TooltipA');
    expect(nodeElements.filter(nodeIdFilter('B'))[0].tip.popper._tippy.props.content.innerHTML).toContain('TooltipB');
    expect(nodeElements.filter(nodeIdFilter('C'))[0].tip.popper._tippy.props.content.innerHTML).toContain('TooltipC');
});

test('Tooltip can be set on a single node after creating a graph instance', () => {
    const graphDefinition = getSampleGraphElementArrays();

    renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges);
    setNodeTooltipText('B', 'TooltipB');

    expect(getGraphElements().filter(graphNodesFilter).filter(nodeIdFilter('B'))[0].tooltipText).toBe('TooltipB');
    
    createTooltips();
    expect(getGraphElements().filter(nodeIdFilter('A'))[0].tip).toBeUndefined();
    expect(getGraphElements().filter(nodeIdFilter('B'))[0].tip.popper._tippy.props.content.innerHTML).toContain('TooltipB');
    expect(getGraphElements().filter(nodeIdFilter('C'))[0].tip).toBeUndefined();
})

test('Default graph layout can be changed after creating an instance', () => {
    const graphDefinition = getSampleGraphElementArrays();
    renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges);

    expect(getGraphElements().filter(nodeIdFilter('B'))[0].json().position.x).toBeCloseTo(-0.38, 1);
    expect(getGraphElements().filter(nodeIdFilter('B'))[0].json().position.y).toBeCloseTo(3.38, 1);

    setGraphLayout('circle');

    expect(getGraphElements().filter(nodeIdFilter('B'))[0].json().position.x).toBeCloseTo(1.38, 1);
    expect(getGraphElements().filter(nodeIdFilter('B'))[0].json().position.y).toBeCloseTo(1.01, 1);
});

test('Graph nodes contain additional data provided in node info on instantiation', () => {
    const graphDefinition = getSampleGraphElementArraysWithData();

    renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges);

    expect(getGraphElements().filter(nodeIdFilter('A'))[0].json().data.text_data_field).toBe('TextA');
    expect(getGraphElements().filter(nodeIdFilter('B'))[0].json().data.text_data_field).toBe('TextB');
    expect(getGraphElements().filter(nodeIdFilter('C'))[0].json().data.text_data_field).toBe('TextC');
    expect(getGraphElements().filter(nodeIdFilter('A'))[0].json().data.numeric_data_field).toBe(100);
    expect(getGraphElements().filter(nodeIdFilter('B'))[0].json().data.numeric_data_field).toBe(200);
    expect(getGraphElements().filter(nodeIdFilter('C'))[0].json().data.numeric_data_field).toBe(300);
});

test('Labels provided in graph initialization data override default label text', () => {
    const graphDefinition = getSampleGraphElementArraysWithLabels();

    renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges, getSampleGraphElementArraysWithLabels());
    
    expect(getGraphElements().filter(nodeIdFilter('A'))[0].json().data.label).toBe('LabelA');
    expect(getGraphElements().filter(nodeIdFilter('B'))[0].json().data.label).toBe('LabelB');
});

describe('Initialize graph with event callbacks', () => {
    let testDone;

    beforeAll(() => {
        let eventCallbacks = {
            onNodeClick: (event) => {
                expect(event.target.id()).toBe('A');
                testDone();
            },

            onNodeCreated: (event) => {
                expect(event.target.id()).toBe('X');
                testDone();
            },

            onEdgeCreated: (event) => {
                expect(event.target.id()).toBe('Y');
                testDone();
            },

            onNodeRemoved: (event) => {
                expect(event.target.id()).toBe('X');
                testDone();
            },

            onEdgeRemoved: (event) => {
                expect(event.target.data().source).toBe('A');
                expect(event.target.data().target).toBe('B');
                testDone();
            }
        };

        const graphDefinition = getSampleGraphElementArrays();
        renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges, null, eventCallbacks);
    });
    
    beforeEach(() => { testDone = null });

    test('onNodeClick event callback returns the id of clicked node', (done) => {
        testDone = done;
        getGraphElements().filter(nodeIdFilter('A'))[0].emit('click');
    });

    test('onNodeCreated event callback returns the new node', (done) => {
        testDone = done;
        getGraphElements().cy().add({ group: 'nodes', data: { id: 'X' } });
    });

    test('onEdgeCreated event callback returns the new edge', (done) => {
        testDone = done;
        getGraphElements().cy().add({ group: 'edges', data: { id: 'Y', source: 'B', target: 'C' } });
    });

    test('onNodeRemoved event callback returns the removed node', (done) => {
        testDone = done;
        getGraphElements().cy().remove('node[id="X"]');
    });

    test('onEdgeRemoved event callback returns the removed edge', (done) => {
        testDone = done;
        getGraphElements().cy().remove('edge[source="A"][target="B"]');
    });
});

describe('Graph elements manipulations', () => {

    test('Add nodes and edges to a graph instance', () => {
        const graphDefinition = getSampleGraphElementArrays();
        renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges);

        addNodes([
            { "id": "X" },
            { "id": "Y" }
        ]);

        addEdges([
            { "source": "A", "target": "X" },
            { "source": "B", "target": "Y" }
        ]);

        expect(getGraphElements().filter(nodeIdFilter('X')).size()).toBe(1);
        expect(getGraphElements().filter(nodeIdFilter('Y')).size()).toBe(1);
        expect(getGraphElements().filter(edgeNodesFilter('A', 'X')).size()).toBe(1);
        expect(getGraphElements().filter(edgeNodesFilter('B', 'Y')).size()).toBe(1);
    });

    test('Remove nodes and edges from a graph instance', () => {
        const graphDefinition = getSampleGraphElementArrays();
        renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges);

        addNodes([{ "id": "X" }]);
        addEdges([{ "source": "C", "target": "X" }]);
        removeEdges([
            { "source": "A", "target": "C" },
            { "source": "C", "target": "X"}
        ]);

        removeNodes([
            { "id": "C" },
            { "id": "X" }
        ]);

        expect(getGraphElements().filter(edgeNodesFilter('A', 'C')).size()).toBe(0);
        expect(getGraphElements().filter(edgeNodesFilter('C', 'X')).size()).toBe(0);
        expect(getGraphElements().filter(nodeIdFilter('C')).size()).toBe(0);
        expect(getGraphElements().filter(nodeIdFilter('X')).size()).toBe(0);
        expect(getGraphElements().filter(graphNodesFilter).size()).toBe(2);
        expect(getGraphElements().filter(graphEdgesFilter).size()).toBe(1);
    });
});

describe('Events on compound nodes', () => {
    let container;

    beforeAll(() => {
        container = document.createElement("div");
        container.style.width = '100px';
        container.style.height = '100px';
        document.body.appendChild(container);
    });

    test('OnNodeClick event called once when a child of a compound node is clicked', (done) => {    
        const onClickHandler = jest.fn(() => { done() });
        renderGraph(
            container,
            [
                { data: {'id': 'A'}, position: { x: 10, y: 10 }},
                { data: {'id': 'B', 'parent': 'A'}, position: { x: 10, y: 10 }}
            ],
            null,  // No edges
            null,  // Use default styles
            null,  // Use default layout
            [onClickHandler]);

        let cy = getGraphElements().cy();
        cy.pan({ x: 0, y: 0 });
        cy.zoom(1);
        cy.viewport({ zoom: 1, pan: { x: 0, y: 0 }});

        document.dispatchEvent(
            new MouseEvent("click", {
                bubbles: true,
                cancelable: true,
                view: window,
                clientX: 10,
                clientY: 10
            })
        );

        expect(onClickHandler).toHaveBeenCalledTimes(1);
    });
});
