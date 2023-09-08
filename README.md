# BCVisuals

Custom control add-ins for Business Central enriching the user experience with JavaScript UI components.
Currently the repository contains one component **CostGraph**.

## CostGraph
A control add-in which traces cost sources for an item ledger entry and displays the cost graph in a convenient way, easy to grasp. Graph representation helps in understanding the cost applcations when a deeper cost analysis is required.

![CostSource1](https://github.com/adrogin/BCVisuals/assets/42849285/048313f8-0005-406d-bd33-d6b79faf20d5)

Graph image is rendered by the Cytoscape package (https://cytoscape.org/). Besides Cytoscape, the CostGraph add-in uses PopperJS (https://popper.js.org/) and Tippy.js (https://atomiks.github.io/tippyjs/) to display tooltips on graph nodes. Project dependencies are saved in the package.json file.
To build the BC extension from the repository, you need to install the dependencies first.

- Clone the repository
- Make sure that the Node.js package manager (npm) is installed in your system or install it: https://nodejs.org/en/download
- Navigate to the repository folder (**cd "\<Your repo root\>/CostGraph"**)
- Run the command **npm i**

That's it. npm will take care of all dependencies. Now you can run Visual Studio Code and build the AL project.

![CostSource2](https://github.com/adrogin/BCVisuals/assets/42849285/359e0cb9-ab87-4e01-8f51-4613c072b70c)
