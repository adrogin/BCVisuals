import { renderGraph, getGraphElements } from "../src/cytograph";
import { getSampleGraphElementArrays, getSampleGraphElementArraysWithTooltips } from "./testutils";

test('Build graph from nodes and edges arrays in format provided by BC', () => {
    const graphDefinition = getSampleGraphElementArrays();

    renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges, null, null); // Undefined container for headless Cytoscape instance
    
    let graphElements = getGraphElements();
    expect(graphElements.size()).toBe(5);

    let nodeElements = graphElements.filter(e => e._private.group == 'nodes');
    let edgeElements = graphElements.filter(e => e._private.group == 'edges');
    expect(nodeElements.size()).toBe(3);
    expect(edgeElements.size()).toBe(2);
    
    expect(nodeElements.filter(e => e._private.data.id == 'A').size()).toBe(1);
    expect(nodeElements.filter(e => e._private.data.id == 'B').size()).toBe(1);
    expect(nodeElements.filter(e => e._private.data.id == 'C').size()).toBe(1);

    expect(edgeElements.filter(e => e._private.data.source == 'A' && e._private.data.target == 'B').size()).toBe(1);
    expect(edgeElements.filter(e => e._private.data.source == 'A' && e._private.data.target == 'C').size()).toBe(1);
});

test('Graph nodes must not have tooltips if the initial dataset does not provide tooltip data', () => {
    const graphDefinition = getSampleGraphElementArrays();

    renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges, null, null);

    getGraphElements().filter(e => e._private.group == 'nodes').forEach(node => {
        expect(node.tip).toBeUndefined();
        expect(node.tooltipText).toBeUndefined();
    });
});

test('Node tooltips must be initialized from the node dataset that contains tooltip info', () => {
    const graphDefinition = getSampleGraphElementArraysWithTooltips();

    renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges, null, null);

    let nodeElements = getGraphElements().filter(e => e._private.group == 'nodes');
    expect(nodeElements.filter(e => e._private.data.id == 'A')[0].tooltipText).toBe('TooltipA');
    expect(nodeElements.filter(e => e._private.data.id == 'B')[0].tooltipText).toBeUndefined();
    expect(nodeElements.filter(e => e._private.data.id == 'C')[0].tooltipText).toBe('TooltipC');

    expect(nodeElements.filter(e => e._private.data.id == 'A')[0].tip.popper._tippy.props.content.innerHTML).toContain('TooltipA');
    expect(nodeElements.filter(e => e._private.data.id == 'B')[0].tip).toBeUndefined();
    expect(nodeElements.filter(e => e._private.data.id == 'C')[0].tip.popper._tippy.props.content.innerHTML).toContain('TooltipC');
});
