# BCVisuals

Custom control add-ins for Business Central enriching the user experience with JavaScript UI components.
Currently the repository contains one component **CostGraph**.

## CostGraph
A control add-in which traces cost sources for an item ledger entry and displays the cost graph in a convenient way, easy to grasp. Graph representation helps in understanding the cost applcations when a deeper cost analysis is required.

![CostSource1](https://github.com/adrogin/BCVisuals/assets/42849285/7202dc38-eb19-4430-8825-29dd681a21ee)


Graph image is rendered by the Cytoscape package (https://cytoscape.org/). Besides Cytoscape, the CostGraph add-in uses PopperJS (https://popper.js.org/) and Tippy.js (https://atomiks.github.io/tippyjs/) to display tooltips on graph nodes. Project dependencies are saved in the package.json file.
To build the BC extension from the repository, you need to install the dependencies first.

- Clone the repository
- Make sure that the Node.js package manager (npm) is installed in your system or install it: https://nodejs.org/en/download
- Navigate to the repository folder (**cd "\<Your repo root\>/CostGraph"**)
- Run the command **npm i**

That's it. npm will take care of all dependencies. Now you can run Visual Studio Code and build the AL project.

![CostSource2](https://github.com/adrogin/BCVisuals/assets/42849285/a6c1fb6e-66d5-43be-b3f6-a4e8a511b767)

## Node Styles
By dwfault, all graph nodes are rendered with the same predefined style, while it may be useful to apply different styles to differentiate various types of entries. For example, highlighting all negative entries in a distinct colour is very helpful in understanding the positive to negative cost flow. Similarly, the cost application graph is easier to read when different entry types are drawn as different shapes. This visual differentiation can be achieved by configuring graph selectors and styles. Import the configuration package **PackageCOSTGRAPH.rapidstart** from the **Config** folder to see an example of the style configuration.

### Example: Negative entries coloured red
![CostSource4](https://github.com/adrogin/BCVisuals/assets/42849285/0183c2b6-8063-4d06-bea3-a195d2e3b196)

### Example: Negative entries in red, and square shapes for production outputs
![CostSource6](https://github.com/adrogin/BCVisuals/assets/42849285/ed9460f4-c9f3-46d6-8cdf-5add2f517167)
