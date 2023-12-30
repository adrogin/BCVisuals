import { renderGraph, getGraphElements, setNodeTooltipText, setNodeTooltipsOnAllNodes, createTooltips } from "../src/cytograph";
import {
    graphNodesFilter, graphEdgesFilter, getSampleGraphElementArrays, getSampleGraphElementArraysWithTooltips, getSampleNodeTooltipsArray,
    nodeIdFilter, edgeNodesFilter
} from "./testutils";

test('Build graph from nodes and edges arrays in format provided by BC', () => {
    const graphDefinition = getSampleGraphElementArrays();

    renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges, null, null); // Undefined container for headless Cytoscape instance
    
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

    renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges, null, null);

    getGraphElements().filter(graphNodesFilter).forEach(node => {
        expect(node.tip).toBeUndefined();
        expect(node.tooltipText).toBeUndefined();
    });
});

test('Node tooltips must be initialized from the node dataset that contains tooltip info', () => {
    const graphDefinition = getSampleGraphElementArraysWithTooltips();

    renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges, null, null);

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

    renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges, null, null);
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

    renderGraph(undefined, graphDefinition.nodes, graphDefinition.edges, null, null);
    setNodeTooltipText('B', 'TooltipB');

    expect(getGraphElements().filter(graphNodesFilter).filter(nodeIdFilter('B'))[0].tooltipText).toBe('TooltipB');
    
    createTooltips();
    expect(getGraphElements().filter(nodeIdFilter('A'))[0].tip).toBeUndefined();
    expect(getGraphElements().filter(nodeIdFilter('B'))[0].tip.popper._tippy.props.content.innerHTML).toContain('TooltipB');
    expect(getGraphElements().filter(nodeIdFilter('C'))[0].tip).toBeUndefined();
})
