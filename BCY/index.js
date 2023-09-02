import {renderGraph} from "./cytograph.js";
renderGraph(
    document.getElementById('cy'), ['1', '2', '3'], [{'1': '2'}, {'2': '3'}, {'3': '1'}]);
