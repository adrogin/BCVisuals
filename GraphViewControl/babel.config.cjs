module.exports = {
    presets: [
      ['@babel/env', {loose: true, useBuiltIns: 'entry', corejs: 3}],
      '@babel/typescript',
    ],
    env: {
      test: {
        presets: [
          ['@babel/env', {targets: {node: 'current'}}],
          '@babel/typescript',
        ],
      },
    },
  };