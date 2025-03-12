import contextMenus from "cytoscape-context-menus";

export function initializeContextMenuItems(cy) {
    if (!cy.contextMenus) {
        cy.contextMenus = [];
    }

    cy.contextMenus.push(
        cy.cxtmenu({
            selector: 'edge',

            commands: [
                {
                    content: 'Remove',
                    tooltipText: 'Remove the selected egde',
                    select: function (target) {
                        target.remove();
                    }
                }
            ]
        }));
}

export function initializeCanvasContextMenuItems(cy, menuItems, onClickCallback) {
    let items = [];

    menuItems.forEach(item => {
        items.push({
            content: item.content,
            select: function () {
                onClickCallback(item.id);
            }
        });
    });

    if (!cy.contextMenus) {
        cy.contextMenus = [];
    }

    cy.contextMenus.push(
        cy.cxtmenu({
            selector: 'core',
            commands: items,
            outsideMenuCancel: 10,
            atMouse: true
        }));

    console.log(cy.contextMenus);
}
