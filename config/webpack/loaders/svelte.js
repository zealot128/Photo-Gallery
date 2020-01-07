module.exports = {
  test: /\.svelte(\.erb)?$/,
  use: [{
    loader: 'svelte-loader',
    options: {
      hotReload: true,
      dev: process.env.NODE_ENV !== 'production',
      preprocess: require('svelte-preprocess')({})
    }
  }],
}
