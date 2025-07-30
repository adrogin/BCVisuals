# BCVisuals

Custom control add-ins for Business Central enriching the user experience with JavaScript UI components.
Currently the repository contains three components:
- **GraphViewControl**: the base application that implements the GraphView control add-in. This is the base layer for other extensions which add more application-specific functionality.
- **CostGraph**: Extends the graph view control presending item ledger applications in a visual graph layout;
- **RoutingGraph**: Another extension on top of the graph view control. Visual presentation of production routings which enables more intuitive editing of complex routings.

Graph image is rendered by the Cytoscape package (https://js.cytoscape.org/). Besides Cytoscape, the GraphViewControl add-in uses PopperJS (https://popper.js.org/) and Tippy.js (https://atomiks.github.io/tippyjs/) to display tooltips on graph nodes. Edge editing functionality is facilitated by the cytoscape-edghandles package (https://github.com/cytoscape/cytoscape.js-edgehandles). fCoSE algorithm for node layout is implemented by the cytoscape.js-fcose package (https://github.com/iVis-at-Bilkent/cytoscape.js-fcose).

All the dependencies are packed and minified by the Webpack bundler, so the control add-in loads a single .js file from the /Scripts/dist folder.
To build the BC extension from the repository, follow these steps.

- Clone the repository
- Make sure that the Node.js package manager (npm) is installed in your system or install it: https://nodejs.org/en/download
- Navigate to the GraphViewControl source folder (**cd "\<Your repo root\>/BCVisuals/GraphViewControl"**)
- Run the command **npm i** - this will install all dependencies
- Run the command **npx webpack**

That's it. npm will take care of all dependencies. File main.js, the entry point of the control add-in, is placed in the /dist folder. Now you can run Visual Studio Code and build the AL project.

## CostGraph
A control add-in which traces cost sources for an item ledger entry and displays the cost graph in a convenient way, easy to grasp. Graph representation helps in understanding the cost applcations when a deeper cost analysis is required.

![CostSource1](https://github.com/adrogin/BCVisuals/assets/42849285/7202dc38-eb19-4430-8825-29dd681a21ee)

There are two ways users can access the cost tracing functionality.
1. Search for the **Cost Source** page and select the source item ledger entry and the cost tracing direction in page controls.
![CostSource2](https://github.com/adrogin/BCVisuals/assets/42849285/a6c1fb6e-66d5-43be-b3f6-a4e8a511b767)

2. Navigate to the **Item Ledger Entries** page or one of the document pages that support cost tracing, select the source entry or the document you want to explore, and choose one of the menu options: **Trace Inbound Cost Applications** or **Trace Outboud Cost Applications**.
![image](https://github.com/user-attachments/assets/6999455f-c521-4267-ba89-47199190a0bd)

Besides item ledger entries, the following document currently support cost graph functionality:
- Posted Purchase Receipt
- Posted Sales Shipment
- Posted Return Receipt
- Posted Return Shipment
- Posted Transfer Shipment
- Posted transfer Receipt
- Released Production Order
- Finished Production Order
- Posted Assembly Order

For all documents, the action can be run from document card pages as well as respective list pages.

### Mouse clicks on graph nodes
Mouse click on a node of the cost graph opens the record (entry or document) this node represents. For nodes corresponding to item ledger entries, click opens the Item Ledger Entries page with the focus on the selected entry. Click on a compound node showing a document, the respective document page will be opened.

![chrome_1Nwqpcqv5a](https://github.com/user-attachments/assets/abd063ba-fef4-4d67-9fd2-7dd8a6a32b6f)


## Node Styles
By default, all graph nodes are rendered with the same predefined style, while it may be useful to apply different styles to differentiate various types of entries. For example, highlighting all negative entries in a distinct colour is very helpful in understanding the positive to negative cost flow. Similarly, the cost application graph is easier to read when different entry types are drawn as different shapes. This visual differentiation can be achieved by configuring graph selectors and styles. Import the configuration package **PackageGRAPHVIEW.rapidstart** from the **Config** folder to see an example of the style configuration.

### Example: Negative entries coloured red
![CostSource4](https://github.com/adrogin/BCVisuals/assets/42849285/0183c2b6-8063-4d06-bea3-a195d2e3b196)

### Example: Negative entries in red, and square shapes for production outputs
![CostSource6](https://github.com/adrogin/BCVisuals/assets/42849285/ed9460f4-c9f3-46d6-8cdf-5add2f517167)

## Node groups
Item ledger entries in the cost layout can be grouped in clusters and presented as compound nodes in the graph.
To enable node groups, open the node set you want to apply to the graph and select table fields to group on in the **Group Fields** section. The following example demonstrates a cost graph with ledger entries grouped by the document type and the document number.

![image](https://github.com/user-attachments/assets/a440d795-1fc1-4323-9e09-4d54cee8ff7d)

Layout of the compound nodes works best with the fCoSE algorithm.
With this configuration, each compound node (yellow rectangle) represents a document, with nodes inside rectangles showing item ledger entries with the same **Document Type** and **Document No.** values.

![CostApplication_fCoSE](https://github.com/user-attachments/assets/e914b61a-2e45-43d6-8645-017dc3358859)


## RoutingGraph
This application simplifies routing setup in Business Central by enabling visual editing of the operations sequence. Drag and drop routing edges to connect operations instead of entering next and previous operations manually. When the edits are saved, the fields "Next Operation No." and "Previous Operation No." in all routing lines are updated to reflect the changes.

To use this functionality:
- Install the applications GraphViewControl and RoutingGraph
- Import the configuration package from the Config folder of the repository. This package includes settings for node styles and tooltips which will be helpful when analysing and editing the graph
- Select the routing you want to edit and open the routing card
- From the routing card, run *Routing -> View as Graph*
- By default, the graph layout opens in a view-only mode. Click **Edit** to enable editing (Note: certified routings cannot be edited. Routing must be in the New or Under Development status to enable editing)
- In the Edit mode, drag and drop actions create new graph edges connecting routing operations. You can delete an edge by right-clicking on it.
- Once all edits are done, push **Save** and close the page

  ![image](https://github.com/adrogin/BCVisuals/assets/42849285/e2f2100b-2a05-4290-ba5b-82ddb4295ab1)

## Application Worksheet
Graph representation of the application worksheet is a part of the CostGraph extension. It can be accessed from the standard Business Central application worksheet and employs the same functionality, replacing the table-based presentation of the item ledger with the graph view.
To access the graph-based application worksheet, open the Application Worksheet page, apply the necessary filters, and run the *View as Graph* action.
![OpenApplicationWorksheet](https://github.com/adrogin/BCVisuals/assets/42849285/16fc639c-13ac-4bc3-b8e0-51940c737a30)

To start editing applications, switch the page to the Edit mode. Remove applications between entries with the right-click on a graph edge and define new applications with a simple drag and drop action.

[![Watch the video](https://img.youtube.com/vi/XU-MhwA6QmA/0.jpg)](https://youtu.be/XU-MhwA6QmA)
