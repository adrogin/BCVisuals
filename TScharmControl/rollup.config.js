import nodeResolve from '@rollup/plugin-node-resolve';
import terser from '@rollup/plugin-terser';
import importCss from "rollup-plugin-import-css";

export default {
	input: [
        'Scripts/tscharmControl.js'
    ],
    output: {
        format: 'iife',
        file: 'dist/main.js',
        name: 'tscharmControl',
        assetFileNames: "[name][extname]"
    },
    plugins: [
        importCss(),
        terser(),
        nodeResolve()
    ]
};
