const HtmlWebpackPlugin = require('html-webpack-plugin')
const path = require('path');
const webpack = require('webpack');
const createElectronReloadWebpackPlugin = require('electron-reload-webpack-plugin');

const isProduction = process.env.NODE_ENV === 'production';
const useElectronConnect = process.env.ELECTRON_CONNECT === 'true';

const ElectronReloadWebpackPlugin = createElectronReloadWebpackPlugin({
    path: path.join(__dirname, './electron.js'),
    logLevel: 0
});

const frontendConfig = {
    mode: isProduction ? 'production' : 'development',
    entry: {
        frontend: `${__dirname}/index.js`
    },
    output: {
            path: `${__dirname}/dist`,
            filename: 'bundle.js',
            libraryTarget: 'window',
    },
    plugins: [useElectronConnect && ElectronReloadWebpackPlugin()].filter(
        Boolean
    ),
    module: {
        rules: [
                {
                    test: /\.(css|scss)$/,
                    loader: ['style-loader', 'css-loader', 'sass-loader'],
                },
                {
                    test:    /\.elm$/,
                    loader: 'elm-webpack-loader',
                }
        ]
    },
    externals: {
        serialport: "serialport"
    },
    target: 'electron-renderer',
    node: {
        __dirname: false
    }
};

const backendConfig = {
    mode: isProduction ? 'production' : 'development',
    entry: {
        backend: `${__dirname}/electron.js`
    },
    output: {
        path: path.resolve(__dirname, 'dist'),
        filename: '[name].js'
    },
    module: {
        rules: [
                {
                    test: /\.(css|scss)$/,
                    loader: ['style-loader', 'css-loader', 'sass-loader'],
                },
                {
                    test:    /\.elm$/,
                    loader: 'elm-webpack-loader',
                }
        ]
    },

    plugins: [useElectronConnect && ElectronReloadWebpackPlugin()].filter(
        Boolean
    ),
    target: 'electron-main',
    node: {
        __dirname: false
    }
};

module.exports = [frontendConfig, backendConfig];
