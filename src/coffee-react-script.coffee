# patches coffee-script module

fs = require 'fs'
csxTransform = require 'coffee-react-transform'

helpers = require './helpers'

CoffeeScript = require 'coffee-script/lib/coffee-script/coffee-script'

CoffeeScript.FILE_EXTENSIONS.push '.csx'

CoffeeScript.register = -> require './register'

# real coffeescript compile func, which we're wrapping
csCompile = CoffeeScript.compile

CoffeeScript.compile = (code, options) ->
  # detect and transform csx by pragma
  input = helpers.hasCSXPragma and csxTransform(code) or code

  csCompile input, options

CoffeeScript._compileFile = (filename, sourceMap = no) ->
  raw = fs.readFileSync filename, 'utf8'
  stripped = if raw.charCodeAt(0) is 0xFEFF then raw.substring 1 else raw

  # detect and transform csx by extension
  input = helpers.hasCSXExtension(filename) and csxTransform(stripped) or stripped

  try
    answer = CoffeeScript.compile(input, {filename, sourceMap, literate: helpers.isLiterate filename})
  catch err
    # As the filename and code of a dynamically loaded file will be different
    # from the original file compiled with CoffeeScript.run, add that
    # information to error so it can be pretty-printed later.
    throw helpers.updateSyntaxError err, input, filename

  answer

CoffeeScript.csxTransform = csxTransform

module.exports = CoffeeScript