
import * as path from 'path'

import * as webpack from 'webpack'

const p = (...s) => path.resolve(__dirname, ...s)
const t = <T>() => <U extends T>(val: U) => val

export default t<webpack.Configuration>()({
  mode: 'none',
  entry: {
    'jell': p('./jell.user.ts')
  },
  output: {
    path: p('./dist'),
    filename: '[name].user.js'
  },
  resolve: {
    extensions: [ '.tsx', '.ts', '.js' ]
  },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        loader: 'ts-loader',
        exclude: /node_modules/,
        options: {
          configFile: p('./tsconfig.userscripts.json')
        }
      }
    ]
  },
})