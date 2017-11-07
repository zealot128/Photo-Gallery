module.exports = {
  "extends": [
    "airbnb-base",
    "plugin:vue/recommended"
  ],
  "globals": {
    OneDrive: true,
    Dropbox: true,
    gapi: true,
    history: true
  },
  "env": {
    "browser": true
  },
  // check if imports actually resolve
  'rules': {
    // don't require .vue extension when importing
    'import/extensions': ['error', 'always', {
      'js': 'never',
      'vue': 'never'
    }],
    'import/no-unresolved': 'off',
    'import/no-extraneous-dependencies': 'off',
    'import/extensions': 'off',
    "import/no-named-as-default": 0,
    // allow debugger during development
    'no-debugger': process.env.NODE_ENV === 'production' ? 2 : 0,
    'no-console': process.env.NODE_ENV === 'production' ? 2 : 0,
    'comma-dangle': 0,
    "semi": 0,
    "arrow-body-style": ["error", "as-needed"],
    "no-param-reassign": 0,
    "no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
    "max-len": ["warn", 200],
    "no-else-return": 0,
    "func-names": ["warn", "as-needed"],
    "vue/valid-template-root": 0,
    "quotes": 0
  }
};
