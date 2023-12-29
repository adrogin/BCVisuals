export function graphNodesFilter(e) {
    return (e._private.group == 'nodes');
};

export function graphEdgesFilter(e) {
    return (e._private.group == 'edges');
};

export function nodeIdFilter(nodeId) {
    return function(e) {
        return (e._private.data.id == nodeId);
    };
};

export function edgeNodesFilter(source, target) {
    return function(e) {
        return (e._private.data.source == source && e._private.data.target == target);
    }
}

export function getSampleGraphElementArrays() {
    return({
            nodes: [
                {'id': 'A'}, {'id': 'B'}, {'id': 'C'}
            ],
            edges: [
                {'source': 'A', target: 'B'},
                {'source': 'A', target: 'C'}
            ]
        });
};

export function getSampleGraphElementArraysWithTooltips() {
    return({
            nodes: [
                {'id': 'A', 'tooltip': 'TooltipA'},
                {'id': 'B'},
                {'id': 'C', 'tooltip': 'TooltipC'}
            ],
            edges: [
                {'source': 'A', target: 'B'},
                {'source': 'A', target: 'C'}
            ]
        });
};

export function getSampleNodeTooltipsArray() {
    return([
        {'nodeId': 'A', 'content': 'TooltipA'},
        {'nodeId': 'B', 'content': 'TooltipB'},
        {'nodeId': 'C', 'content': 'TooltipC'}
    ]);
}
