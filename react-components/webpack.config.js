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

  resolve: {
    extensions: [".js", ".jsx", ".ts", ".tsx"],
  },

  module: {
    rules: [
      {
        test: /\.(js|jsx|ts|tsx)$/,
        exclude: /node_modules/,
        use: {
          loader: "awesome-typescript-loader",
        }
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
              modules: true,
              sourceMap: true,
              localIdentName: '[local]--[hash:base64:8]',
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
        loader: 'url-loader',
        options: {
          // set limit to a very large number so that all assets are bundled into the css file
          // TODO: newer webpack versions allow for false to disable the limit
          limit: 1000000
        }
      }
    ]
  },
  externals: {
    'jquery': 'jQuery',
  }
}
