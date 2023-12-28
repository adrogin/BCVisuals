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
