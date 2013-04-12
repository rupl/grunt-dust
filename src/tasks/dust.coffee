###
# grunt-dust
# https://github.com/vtsvang/grunt-dust
#
# Copyright (c) 2013 Vladimir Tsvang
# Licensed under the MIT license.
###

module.exports = ( grunt ) ->
	# Link to Underscore.js
	_ = grunt.util._

	dust = require "dustjs-linkedin"
	path = require "path"
	fs = require "fs"

	# ==========================================================================
	# HELPERS
	# ==========================================================================
	amdHelper = require( "../helpers/amd" ).init( grunt )

	# Runtime options
	runtime =
		path: grunt.file.expand( path.join( __dirname, "..", "..", "node_modules", "dustjs-linkedin", "dist", "dust-core-*.js" ) )[ 0 ]
		file: "dust-runtime.js"
		amdName: "dust-runtime"

	# ==========================================================================
	# TASKS
	# ==========================================================================

	# Task to compile dustjs templates
	# ---
	grunt.registerMultiTask "dust", "Task to compile dustjs templates.", ->
		options = @options
			runtime: on
			amd:
				packageName: null
				deps: [ runtime.amdName ]

		grunt.verbose.writeflags options, "Options"

		# exclude deps if runtime is false
		unless options.runtime or @data.options?.amd?.deps? and runtime.amdName in @data.options.amd.deps
			options.amd.deps = _.without( options.amd.deps, runtime.amdName )

		for own file in @files

			output = []

			for own source in file.src
				try
					output.push "// #{ source }\n" + dust.compile grunt.file.read( source ), source
				catch e
					# Handle error and log it with Grunt.js API
					grunt.log.error().writeln e.toString()
					grunt.warn "DustJS found errors.", 10

			if output.length > 0
				grunt.file.write file.dest, if options.amd then amdHelper( output.join( "\n" ), options.amd.deps ? [], options.amd.packageName ? "" ) else output.join( "\n" ) ? ""

			# Add runtime
			if options.runtime
				# Where to store runtime
				runtimePath = path.join ( if fs.statSync( fs.realpathSync file.orig.dest ).isDirectory() then  file.orig.dest else path.dirname( file.orig.dest ) ), runtime.file

				# Save runtime to file
				grunt.file.write runtimePath, grunt.file.read( runtime.path )

