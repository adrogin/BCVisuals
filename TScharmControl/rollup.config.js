import nodeResolve from '@rollup/plugin-node-resolve';
import terser from '@rollup/plugin-terser';

export default {
	input: [
        'Scripts/tscharmControl.js'
    ],
    output: {
        format: 'iife',
        file: 'dist/main.js',
        name: 'tscharmControl'
    },
    plugins: [
        terser(),
        nodeResolve()
    ]
};
