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
