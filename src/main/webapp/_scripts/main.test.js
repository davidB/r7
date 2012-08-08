require.config({
//  baseUrl : '_scripts',
  urlArgs: "bust=" +  (new Date()).getTime(),
  enforceDefine: true,
  paths: {
    'jasmine' : '../_vendors/jasmine-1.1.0.rc1/jasmine',
    'jasmine-html' : '../_vendors/jasmine-1.1.0.rc1/jasmine-html'
  },
  shim: {
    'jasmine' : {
      deps: [],
      exports: 'jasmine'
    },
    'jasmine-html' : {
      deps: ['jasmine'],
      exports: 'jasmine.TrivialReporter'
    }
  }
});

define('main.test', [
  'jasmine',
  'jasmine-html',
	//include all specs to be run
	'r7/evt.test',
	'r7/Ring.test',
	'r7/Stage4GameRules.test'
], function(jasmine) {
	//run tests
	jasmine.getEnv().addReporter(new jasmine.TrivialReporter());
	jasmine.getEnv().execute();
});

require(['main.test'], function(){});
