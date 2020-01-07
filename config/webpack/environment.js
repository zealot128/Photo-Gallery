const { environment } = require('@rails/webpacker')
const svelte = require('./loaders/svelte')
const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')
const pug = require('./loaders/pug')

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vue)
environment.loaders.append('pug', pug)
environment.loaders.prepend('svelte', svelte)
module.exports = environment
