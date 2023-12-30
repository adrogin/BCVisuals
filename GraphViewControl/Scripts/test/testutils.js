export function graphNodesFilter(e) {
    return (e.json().group == 'nodes');
};

export function graphEdgesFilter(e) {
    return (e.json().group == 'edges');
};

export function nodeIdFilter(nodeId) {
    return function(e) {
        return (e.json().data.id == nodeId);
    };
};

export function edgeNodesFilter(source, target) {
    return function(e) {
        return (e.json().data.source == source && e.json().data.target == target);
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
