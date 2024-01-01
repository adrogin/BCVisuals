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

export function getSampleGraphElementArraysWithData() {
    return({
            nodes: [
                {
                    'id': 'A',
                    'tooltip': 'TooltipA',
                    'text_data_field': 'TextA',
                    'numeric_data_field': 100
                },
                {
                    'id': 'B',
                    'text_data_field': 'TextB',
                    'numeric_data_field': 200
                },
                {
                    'id': 'C',
                    'tooltip': 'TooltipC',
                    'text_data_field': 'TextC',
                    'numeric_data_field': 300
                }
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
};
