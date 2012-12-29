#!/bin/sh
SCRIPT="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
DIR=`dirname "${SCRIPT}"}`
exec scala -save -nc -cp "$DIR/tools/lib/plob-0.2.0-SNAPSHOT.jar:$DIR/tools/lib/compiler.jar" $0 $*
::!#

import plob.AnnotedPathGenerator
import plob._
import plob.builders._

object Main {
  def main(args : Array[String]) {
    main2(args)
  }

  def main2(args : Array[String]) {
    val closureCompiler = b.Compiler_GoogleClosureCompiler("target/webapp/_scripts", List(
      "--compilation_level", "ADVANCED_OPTIMIZATIONS"
      , "--warning_level=VERBOSE"
      , "--jscomp_warning", "accessControls"
      , "--jscomp_warning", "checkRegExp"
      , "--language_in", "ECMASCRIPT5_STRICT"
      , "--jscomp_off", "externsValidation"
      , "--jscomp_off", "globalThis" // for Three.js
      , "--transform_amd_modules"
      //, "--process_common_js_modules"
      //, "--common_js_entry_module", "src/webapp/_scripts/main_r7"
      //, "--externs", "src/webapp/_vendors/requirejs/1.0.2/require.js"
      , "--externs", "src/js_externs/global.js"
      , "--externs", "src/js_externs/require.js"
      , "--externs", "src/js_externs/jasmine.js"
    ))
    var build = builders.pipe(
      builders.route(
        ("glob:src/webapp/_scripts/**.coffee", builders.pipe(
          b.Compiler_CoffeeScript("src/webapp/_scripts", "target/gen_js", List("--bare"))
        , b.Misc_Sync("target/gen_js", "target/webapp/_scripts")
        ))
//        ("glob:src/webapp/_scripts/**.js", closureCompiler)
//        , ("glob:target/gen_js/**.js", closureCompiler)
        , ("glob:src/webapp/**.jade", b.Compiler_Jade("src/webapp", "target/webapp"))
        , ("glob:src/webapp/**", b.Misc_Sync("src/webapp", "target/webapp"))
      ),
      builders.route(
        ("glob:src/test/vows/**.js", b.Checker_Vows("."))
      )
        //, JadeCompiler("src/jade", "glob:**/*.jade", "target/webapp"),
        //, CoffeeScriptCompiler2("src/test/coffee", "glob:**/*.coffee", "target/webapp"),
        //, VowsRunner("src/test/coffee", "glob:**/*.js")
    )
// node r.js src/test/vows/modules.test.js 
// vows src/test/vows/modules.test.js --json
    val input = new AnnotedPathGenerator("src")
    for(arg <- args) arg match {
      case "all" => input.runAllOnce(build, basicResultsConsolePrinter )
      case "watch" => input.watch(build, basicResultsConsolePrinter)
      case "setup" => b.Checker_Vows.setup()
      case x => println("unsupported argument '%s'".format(x))
    }
    println("DONE")
  }
}
