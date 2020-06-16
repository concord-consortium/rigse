const path = require('path')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')

const destFolder = path.resolve(__dirname, 'dist')
const devMode = process.env.NODE_ENV !== 'production'

module.exports = {
  // development mode makes webpack-server reload pages faster
  mode: devMode ? 'development' : 'production',
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
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env', '@babel/preset-react']
          }
        }
      },
      {
        test: [/node_modules[\\/].*\.(css|scss)$/, /library.scss$/],
        use: [
          {
            loader: devMode ? 'style-loader' : MiniCssExtractPlugin.loader
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
            loader: devMode ? 'style-loader' : MiniCssExtractPlugin.loader
          },
          {
            loader: 'css-loader',
            options: {
              modules: true,
              sourceMap: true,
              localIdentName: '[local]--[hash:base64:8]'
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
          limit: 10000,
          // This assumes all assets greater than 10000k,
          // should go in the assets folder.
          // In practice this is fine, but it is a bit weird because some assets might
          // be located outside of the src/library folder
          outputPath: 'assets'
        }
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin(
      {
        // Options similar to the same options in webpackOptions.output
        // both options are optional
        filename: '[name].css',
        // TODO figure out what this does
        chunkFilename: '[id].css'
      }
    )
  ],
  externals: {
    'jquery': 'jQuery',
  }
}
