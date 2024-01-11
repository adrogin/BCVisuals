import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export default {
    entry: './Scripts/src/index.js',
    module: {
        rules: [
            {
                test: /\.js$/,
                loader: 'babel-loader',
                include: [
                    path.resolve(__dirname, 'Scripts/src/')
                ],
            },
            {
                test: /\.css$/,
                use: ['style-loader', 'css-loader'],
            },       
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
