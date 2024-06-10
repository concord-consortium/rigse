const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

// `railsAssetsPath` needs to match `config.assets.prefix` in Rails.
// If you change it in Rails, you need to change it here as well.
const railsAssetsPath = '/assets/builds/';
const jsDestFolder = path.resolve(__dirname, '../app/assets/javascripts/builds');
const devMode = process.env.NODE_ENV !== 'production';

module.exports = {
  mode: devMode ? 'development' : 'production',
  devtool: devMode ? 'inline-source-map' : false,
  entry: {
    'react-components': './src/library/library.tsx',
    'react-test-globals': './src/react-test-globals.ts'
  },
  output: {
    path: jsDestFolder,
    filename: '[name].js',
    publicPath: railsAssetsPath
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
            loader: MiniCssExtractPlugin.loader
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
            loader: MiniCssExtractPlugin.loader
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
        type: 'asset/resource',
        generator: {
          filename: '[name][hash][ext]'
        }
      }
    ]
  },
  resolve: {
    extensions: ['.js', '.jsx', '.ts', '.tsx'],
  },
  externals: {
    'jquery': 'jQuery'
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: '../../stylesheets/builds/[name].css',
    }),
  ],
};
