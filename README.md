# BCVisuals

Custom control add-ins for Business Central enriching the user experience with JavaScript UI components.
Currently the repository contains three components:
- **GraphViewControl**: the base application that implements the GraphView control add-in. This is the base layer for other extensions which add more application-specific functionality.
- **CostGraph**: Extends the graph view control presending item ledger applications in a visual graph layout;
- **RoutingGraph**: Another extension on top of the graph view control. Visual presentation of production routings which enables more intuitive editing of complex routings.

Graph image is rendered by the Cytoscape package (https://cytoscape.org/). Besides Cytoscape, the GraphViewControl add-in uses PopperJS (https://popper.js.org/) and Tippy.js (https://atomiks.github.io/tippyjs/) to display tooltips on graph nodes. Edge editing functionality is facilitated by the cytoscape-edghandles package (https://github.com/cytoscape/cytoscape.js-edgehandles). 
All the dependencies are packed and minified by the Webpack bundler, so the control add-in loads a single .js file from the /Scripts/dist folder.
To build the BC extension from the repository, follow these steps.

- Clone the repository
- Make sure that the Node.js package manager (npm) is installed in your system or install it: https://nodejs.org/en/download
- Navigate to the GraphViewControl source folder (**cd "\<Your repo root\>/BCVisuals/GraphViewControl"**)
- Run the command **npm i** - this will install all dependencies
- Run the command **npx webpack**

That's it. npm will take care of all dependencies. File main.js, the entry point of the control add-in is placed the /dist folder. Now you can run Visual Studio Code and build the AL project.

## CostGraph
A control add-in which traces cost sources for an item ledger entry and displays the cost graph in a convenient way, easy to grasp. Graph representation helps in understanding the cost applcations when a deeper cost analysis is required.

![CostSource1](https://github.com/adrogin/BCVisuals/assets/42849285/7202dc38-eb19-4430-8825-29dd681a21ee)


![CostSource2](https://github.com/adrogin/BCVisuals/assets/42849285/a6c1fb6e-66d5-43be-b3f6-a4e8a511b767)

## Node Styles
By default, all graph nodes are rendered with the same predefined style, while it may be useful to apply different styles to differentiate various types of entries. For example, highlighting all negative entries in a distinct colour is very helpful in understanding the positive to negative cost flow. Similarly, the cost application graph is easier to read when different entry types are drawn as different shapes. This visual differentiation can be achieved by configuring graph selectors and styles. Import the configuration package **PackageCOSTGRAPH.rapidstart** from the **Config** folder to see an example of the style configuration.

### Example: Negative entries coloured red
![CostSource4](https://github.com/adrogin/BCVisuals/assets/42849285/0183c2b6-8063-4d06-bea3-a195d2e3b196)

### Example: Negative entries in red, and square shapes for production outputs
![CostSource6](https://github.com/adrogin/BCVisuals/assets/42849285/ed9460f4-c9f3-46d6-8cdf-5add2f517167)

## RoutingGraph
This application simplifies routing setup in Business Central by enabling visual editing of the operations sequence. Drag and drop routing edges to connect operations instead of entering next and previous operations manually. When the edits are saved, the fields "Next Operation No." and "Previous Operation No." in all routing lines are updated to reflect the changes.

To use this functionality:
- Install the applications GraphViewControl and RoutingGraph
- Import the configuration package from the Config folder of the repository. This package includes settings for node styles and tooltips which will be helpful when analysing and editing the graph
- Select the routing you want to edit and open the routing card
- From the routing card, run Routing -> View as Graph
- By default, the graph layout opens in view-only mode. Click **Edit** to enable editing (Note: certified routings cannot be edited. Routing must be in the New or Under Development to enable editing)
- In the Edit mode, drag and drop actions create new graph edges connecting routing operations. You delete a node by right-clicking on it.
- Once all edits are done, push **Save** the close the page

  ![image](https://github.com/adrogin/BCVisuals/assets/42849285/e2f2100b-2a05-4290-ba5b-82ddb4295ab1)
