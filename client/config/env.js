'use strict';

function getClientEnvironment() {
  var raw = Object
    .keys(process.env)
    .reduce((env, key) => {
      env[key] = process.env[key];
      return env;
    }, {
      'NODE_ENV': process.env.NODE_ENV || 'development'
    });

  var stringified = {
    'process.env': Object
      .keys(raw)
      .reduce((env, key) => {
        env[key] = JSON.stringify(raw[key]);
        return env;
      }, {})
  };

  return { raw, stringified };
}

module.exports = getClientEnvironment;