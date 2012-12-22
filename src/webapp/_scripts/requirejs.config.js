//retreive the base url of scripts (to run from playcanvas launch local)
var baseUrl = '/_scripts';
var l = document.scripts;
for (var i = l.length-1; i > -1; i--) {
  var v = l[i].src;
  var p = v.indexOf('requirejs.config.js');
  if (p > -1) baseUrl = v.substring(0, p);
}
console.log('baseUrl', baseUrl);
require.config({
  baseUrl: baseUrl,
  //enforceDefine: true,
  paths: {
    'underscore': '../_vendors/underscore-1.4.2/underscore.min',
    'Stats': '../_vendors/stats-r8/Stats',
    'THREE': '../_vendors/three-r53/three',
    'ThreeBSP' : '../_vendors/threeCSG-20120615/ThreeCSG',
    'dat' : '../_vendors/dat-gui-20111206/dat.gui.min',
    'ko' : '../_vendors/knockout-2.2.0',
    'Box2D' : '../_vendors/box2dweb-2.1alpha/Box2D.min',
    'd3' : '../_vendors/d3.v2.min',
    'jquery' : [
      'http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min',
      //LOAD FROM THIS LOCATION IF THE CDN LOCATION FAILS
      '../_vendors/jquery-1.7.1/jquery-1.7.1.min'
    ],
    'bootstrap' : '../_vendors/bootstrap/js/bootstrap.min',
    // polyfil
    'webglDetector' : '../_vendors/three-r49/Detector',
    'console' : '../_vendors/console_log',
    'requestAnimationFrame' : '../_vendors/RequestAnimationFrame',
    // test

    'jasmine' : '../_vendors/jasmine-1.2.0/jasmine',
    'jasmine-html' : '../_vendors/jasmine-1.2.0/jasmine-html',
    // requirejs plugins
    'domReady' : '../_vendors/requirejs-2.1.1/domReady'
  },
  shim: {
    'bootstrap':      { deps: ['jquery'] },
    'underscore':     { deps: [], exports: '_' },
    'dat':            { deps: [], exports: 'dat' },
    'THREE' :         { deps: [], exports: 'THREE' },
    'ThreeBSP' :      { deps: ['THREE'], exports: 'ThreeBSP' },
    'webglDetector' : { deps: [], exports: 'Detector'},
    'Stats' :         { deps: [], exports: 'Stats' },
    'd3' :            { deps: [], exports: 'd3' },
    'Box2D' :         { deps: [], exports: 'Box2D' },
    'jasmine' :       { deps: [], exports: 'jasmine'},
    'jasmine-html' :  { deps: ['jasmine'], exports: 'jasmine.TrivialReporter'}
  },
  config: {
    'r7/Stage4Layer2D': {
      baseUrl: baseUrl + '../'
    }
  },
  waitSeconds: 15,
  locale: "fr-fr"
});
define('requirejs.config', [], function(){});
