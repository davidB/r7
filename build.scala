#!/bin/sh
SCRIPT="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
DIR=`dirname "${SCRIPT}"}`
exec scala -save -nc -cp "$DIR/tools/lib/plob-0.1.0-SNAPSHOT.jar:$DIR/tools/lib/compiler.jar" $0 $*
::!#

import plob.AnnotedPathGenerator
import plob._
import plob.builders._

object Main {
  def main(args : Array[String]) {
    main2(args)
  }

  def main2(args : Array[String]) {
    val closureCompiler = my.Compiler_GoogleClosureCompiler("target/webapp/_scripts", List(
      "--compilation_level", "ADVANCED_OPTIMIZATIONS"
      , "--warning_level=VERBOSE"
      , "--jscomp_warning", "accessControls"
      , "--jscomp_warning", "checkRegExp"
      , "--language_in", "ECMASCRIPT5_STRICT"
      , "--jscomp_off", "externsValidation"
      , "--jscomp_off", "globalThis" // for Three.js
      , "--transform_amd_modules"
      //, "--process_common_js_modules"
      //, "--common_js_entry_module", "src/main/webapp/_scripts/main_r7"
      //, "--externs", "src/main/webapp/_vendors/requirejs/1.0.2/require.js"
      , "--externs", "externs_require.js"
      , "--externs", "externs_jquery-1.7.js"
    ))
    var build = builders.pipe(
//      builders.route(
//        ("glob:src/main/coffee/**.coffee", Compiler_CoffeeScript("src/main/coffee", "target/gen_js", List("--bare")))
//      ),  
      builders.route(
        ("glob:src/main/webapp/_scripts/**.js", closureCompiler)
        , ("glob:target/gen_js/**.js", closureCompiler)
        , ("glob:src/main/jade/**.jade", Compiler_Jade("src/main/jade", "target/webapp"))
        , ("glob:src/main/webapp/**", Misc_Sync("src/main/webapp", "target/webapp"))
      ),
      builders.route(
        ("glob:src/test/vows/**.js", my.Checker_Vows("."))
      )
        //, JadeCompiler("src/main/jade", "glob:**/*.jade", "target/webapp"),
        //, CoffeeScriptCompiler2("src/test/coffee", "glob:**/*.coffee", "target/webapp"),
        //, VowsRunner("src/test/coffee", "glob:**/*.js")
    )
// node r.js src/test/vows/modules.test.js 
// vows src/test/vows/modules.test.js --json
    val input = new AnnotedPathGenerator("src")
    for(arg <- args) arg match {
      case "all" => input.runAllOnce(build, basicResultsConsolePrinter )
      case "watch" => input.watch(build, basicResultsConsolePrinter)
      case "setup" => my.Checker_Vows.setup()
      case x => println("unsupported argument '%s'".format(x))
    }
    println("DONE")
  }

object my {
object Checker_Vows {
  import java.nio.file.Path
 
  import scala.sys.process.ProcessLogger
  class ProcessLoggerAnnotedPath(who : String, change : Change, path : Path, outLevel : Level = Level.Info, errLevel : Level = Level.Warning) extends ProcessLogger {
    private var _annotedPaths : List[AnnotedPath] = Nil

    def annotedPaths = _annotedPaths.toList
    def out(s: => String): Unit = { _annotedPaths = AnnotedPath(change, path, Set(Marker("vows", s, outLevel))) :: _annotedPaths }
    def err(s: => String): Unit = { _annotedPaths = AnnotedPath(change, path, Set(Marker("vows", s, errLevel))) :: _annotedPaths }
    def buffer[T](f: => T): T = f
//    def close(): Unit = writer.close()
//    def flush(): Unit = writer.flush()
  }
  def setup(version : Option[String] = None) {
    //TODO check node + npm are installed
    //TODO check vows is installed (npm test vows@version) else npm install vows@version
  }

  // TODO implement
  // TODO monitor outputDir, if deleted => rebuild all (how ?)
  def apply(inputDir : Path, options : Seq[String] = Nil) : builders.Builder = {
  //TODO init : check node is installed + npm install vows
    return { apaths : builders.AnnotedPathS =>
      import scala.sys.process.{Process, BasicIO}
      var back = apaths.toList
      println(inputDir, inputDir.toFile.getAbsolutePath)
      val files = builders.toRelativeFilePaths(apaths, inputDir).toList
      println(files)
      //val files = apaths.map(g)
      //val cmdline = "node" :: options.toList ::: files
      val cmdline = "vows" :: /*"--json"*/ "--dot-matrix" :: options.toList ::: files
      back = AnnotedPath(Change.Modified, inputDir, Set(Marker("vows", "cmdline :" + cmdline.mkString("'", "' '", "'"), Level.Debug))) :: back
      val logger = new ProcessLoggerAnnotedPath("vows", Change.Modified, inputDir)
      val p = Process(cmdline, inputDir.toFile)
     
      val exitValue = p !< logger
      back = logger.annotedPaths ::: back
      if (exitValue != 0) {
        back = AnnotedPath(Change.Modified, inputDir, Set(Marker("vows", "exit value : " + exitValue, Level.Error))) :: back
      }
      //TODO parse output to log into back 
      back
    }
  }

}
object Compiler_CoffeeScript {
  import java.nio.file.Path
  
  // TODO implement
  // TODO monitor outputDir, if deleted => rebuild all (how ?)
  def apply(inputDir : Path, outputDir : Path, options : Seq[String] = Nil) : builders.Builder = {
    //TODO init (eg create outputDir),
    //TODO check context (eg coffee executable existe, else warning and fallback to rhino + ...)
    //TODO return a Validation or a Logger ??
    //TODO manage Deleted 
    return { apaths : builders.AnnotedPathS =>
      import scala.sys.process.Process
      var back = apaths.toList
      val files = builders.toRelativeFilePaths(apaths, inputDir).toList
      val dest = outputDir.toFile
      dest.mkdirs()
      val cmdline = "coffee" :: "-o" :: dest.getAbsolutePath :: options.toList ::: files 
      back = AnnotedPath(Change.Modified, inputDir, Set(Marker("coffee", "cmdline :" + cmdline.mkString("'", "' '", "'"), Level.Debug))) :: back
      val stdout: String = Process(cmdline, inputDir.toFile) !!;
      println(stdout)
      back
    }
  }
 //def apply(inputDir : Path, inputFilter : builders.Filter, outputDir : Path, options : Seq[String] = Nil) : builders.Builder = builders.route((inputFilter, exec(inputDir, outputDir, options)))

}

object Compiler_GoogleClosureCompiler {
  // see http://blog.bolinfest.com/2009/11/calling-closure-compiler-from-java.html

  import java.nio.file.Path
  
  // TODO implement
  // TODO monitor outputDir, if deleted => rebuild all (how ?)
  def apply(outputDir : Path, options : Seq[String] = Nil) : builders.Builder = {
    //TODO init (eg create outputDir),
    //TODO generate annothed path as reporter of the compiler, provide a custom com.google.javascript.jscomp.ErrorManager
    //TODO support requirejs (config)

    import com.google.javascript.jscomp.CompilationLevel
    import com.google.javascript.jscomp.Compiler
    import com.google.javascript.jscomp.CompilerOptions
    import com.google.javascript.jscomp.JSSourceFile
    import com.google.javascript.jscomp.{CommandLineRunner, BasicErrorManager, CheckLevel, JSError}
    import java.nio.charset.Charset
    //import scala.collection.JavaConversions._
    import scala.collection.JavaConverters._
    return { apaths : builders.AnnotedPathS =>
      var back = apaths.toList
      //TODO parse options 
      //HACK create a CommandLineRunner to parse options
      class MyCommandLineRunner(args : Seq[String]) extends CommandLineRunner(args.toArray){
        override def createOptions() = super.createOptions() // protected => public
        override def createExterns() = super.createExterns()
        override def createCompiler() = super.createCompiler()
      }
      def toAnnotedPath(v: JSError) : AnnotedPath = {
        val l = v.getDefaultLevel match {
          case CheckLevel.ERROR => Level.Error
          case CheckLevel.WARNING => Level.Warning
          case CheckLevel.OFF => Level.Trace  
        }
        println(v.sourceName)
        AnnotedPath(Change.Modified, toPath(Option(v.sourceName).getOrElse("")), Set(Marker("closure-compiler",  v.getType.key + ":" + v.description, l, Option(/*Position.Range(v.getNodeSourceOffset, v.getNodeLength)*/ Position.LC(v.lineNumber, -1)))))
      }
      val cli = new MyCommandLineRunner(options)
      val compiler = cli.createCompiler()
      compiler.setErrorManager(new BasicErrorManager(){
        def println(level : CheckLevel, error: JSError) {
    //      System.err.println("----- " +  level + " -- "+ error)
          back = toAnnotedPath(error) :: back
        }
        def printSummary() {}
      })
      val coptions = cli.createOptions()
      // Advanced mode is used here, but additional options could be set, too.
      //CompilationLevel.ADVANCED_OPTIMIZATIONS.setOptionsForCompilationLevel(coptions)
      // To get the complete set of externs, the logic in CompilerRunner.getDefaultExterns() should be used here.
      val externs = cli.createExterns()//CommandLineRunner.getDefaultExterns()
      //val externs = JSSourceFile.fromCode("externs.js", "function alert(x) {}")
      println("call", back)
      //val files = builders.toRelativeFilePaths(apaths, inputDir).map(f => JSSourceFile.fromFile(f, Charset.forName("utf-8"))).toList.asJava
      val files = apaths.map(ap => JSSourceFile.fromFile(ap.path.toFile, Charset.forName("utf-8"))).toList.asJava
      val dest = outputDir.toFile
      dest.mkdirs()
      //back = AnnotedPath(Change.Modified, inputDir, Set(Marker("closure-compiler", "running", Level.Debug))) :: back
      //val stdout: String = Process(cmdline, inputDir.toFile) !!;      
      //println(stdout)

      val result = compiler.compile(externs, files, coptions)
      /*
      back = result.warnings.toList.map{ i =>
      } ::: back
      back = result.errors.toList.map{ i =>
      AnnotedPath(Change.Modified, toPath(Option(i.sourceName).getOrElse("")), Set(Marker("closure-compiler",  i.getType.key + ":" + i.description, Level.Error, Option(/*Position.Range(i.getNodeSourceOffset, i.getNodeLength)*/ Position.LC(i.lineNumber, -1)))))
      } ::: back
      */
      //compiler.toSource()
      back
    }
  }
 //def apply(inputDir : Path, inputFilter : builders.Filter, outputDir : Path, options : Seq[String] = Nil) : builders.Builder = builders.route((inputFilter, exec(inputDir, outputDir, options)))

}


object Compiler_Jade {
  import java.nio.file.Path
  
  // TODO implement
  def apply(inputDir : Path, outputDir : Path, options : Seq[String] = Nil) : builders.Builder = { apaths : builders.AnnotedPathS =>
    import scala.sys.process.Process

    val files = builders.toRelativeFilePaths(apaths, inputDir).toList
    val dest = outputDir.toFile
    dest.mkdirs()
    val cmdline = "jade" ::  "--out" :: dest.getAbsolutePath :: options.toList ::: files
    val listed: String = Process(cmdline , inputDir.toFile) !!;
    println(listed)
    apaths
  }

 //ef apply(inputDir : Path, inputFilter : builders.Filter, outputDir : Path, options : Seq[String] = Nil) : builders.Builder = builders.route((inputFilter, exec(inputDir, outputDir, options)))

}

object Misc_Sync {
  import java.nio.file.Files
  import java.nio.file.LinkOption
  import java.nio.file.Path
  import java.nio.file.StandardCopyOption

  // TODO implement
  def apply(inputDir : Path, outputDir : Path) : builders.Builder = { apaths : builders.AnnotedPathS =>
    val n = for (apath <- apaths) yield {
      val src = apath.path
      val dest = outputDir.resolve(inputDir.relativize(src))
      (src.toFile.isDirectory, apath.change) match {
        case (_, Change.Deleted) => Files.deleteIfExists(dest) //TODO delete recursivly for Directory
        case (true, _) => dest.toFile.mkdirs
        case (_, _) => {
          dest.toFile.getParentFile.mkdirs()
          Files.copy(src, dest, StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.COPY_ATTRIBUTES, LinkOption.NOFOLLOW_LINKS)
        }
      }

      AnnotedPath(apath.change, dest)
    }
    n ++ apaths
  }

  def apply(inputDir : Path, inputFilter : builders.Filter, outputDir : Path) : builders.Builder = builders.route((inputFilter, apply(inputDir, outputDir)))

}
}

}
