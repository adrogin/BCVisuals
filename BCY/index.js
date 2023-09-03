import {renderGraph} from "./cytograph.js";

function DrawGraph(containerElementName, nodes, edges) {
    renderGraph(document.getElementById(containerElementName), nodes, edges);
};

export default DrawGraph;