const path = require('path')

const destFolder = path.resolve(__dirname, 'dist')
const devMode = process.env.NODE_ENV !== 'production'

module.exports = {
  // development mode makes webpack-server reload pages faster
  mode: devMode ? 'development' : 'production',
  devtool: devMode ? 'inline-source-map' : false,
  entry: {
    'react-components': './src/library/library.js',
    'react-test-globals': './src/react-test-globals.js'
  },
  output: {
    // path: path.resolve(destFolder, './library'),
    path: destFolder,
    filename: '[name].js',
    // publicPath: '../'
  },

  module: {
    rules: [
      {
        test: /\.tsx?$/,
        loader: 'ts-loader',
      },
      {
        test: [/node_modules[\\/].*\.(css|scss)$/, /library.scss$/],
        use: [
          {
            loader: 'style-loader',
          },
          {
            loader: 'css-loader'
          },
          {
            loader: 'sass-loader'
          }
        ]
      },
      {
        test: /\.(css|scss)$/,
        exclude: [/node_modules/, /library.scss$/],
        use: [
          {
            loader: 'style-loader'
          },
          {
            loader: 'css-loader',
            options: {
              esModule: false,
              modules: {
                localIdentName: '[local]--[hash:base64:8]'
              },
              sourceMap: true,
              importLoaders: 1
            }
          },
          {
            loader: 'sass-loader'
          }
        ]
      },
      {
        test: /\.(png|jpg|gif|svg|eot|ttf|woff|woff2)$/,
        // All assets are bundled into the JS file. This is currently required because of the Rails pipeline and
        // the build system of this package.
        type: 'asset/inline',
      }
    ]
  },
  externals: {
    'jquery': 'jQuery',
  }
}
