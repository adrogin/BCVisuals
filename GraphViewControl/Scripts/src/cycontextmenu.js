export function initializeContextMenu(cy) {
    cy.contextMenu = cy.contextMenus({
        menuItems: [
            {
                id: 'remove',
                content: 'Remove',
                tooltipText: 'Remove the selected egde',
                selector: 'edge',
                onClickFunction: function (event) {
                    var target = event.target || event.cyTarget;
                    target.remove();
                },

                hasTrailingDivider: true
            }
        ]
    })

    return cy.contextMenu;
}
