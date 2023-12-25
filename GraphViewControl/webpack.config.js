const path = require('path');

module.exports = {
    entry: './Scripts/src/index.js',
    module: {
        rules: [
            {
                test: /\.js$/,
                loader: 'babel-loader',
                include: [
                    path.resolve(__dirname, 'Scripts/src/')
                ],
            }
        ]
    },
    output: {
        filename: 'main.js',
        path: path.resolve(__dirname, 'Scripts/dist/'),
        library: {
            type: 'window',
        }
    }
};