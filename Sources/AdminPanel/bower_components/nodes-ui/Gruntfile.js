module.exports = function(grunt) {

	// Define project configuration
	var project = {
		paths: {
			get config() {
				return this.grunt + 'config/';
			},
			dist: 'dist/',
			doc: 'doc/',
			grunt: 'grunt/',
			js: 'js/',
			scss: 'scss/',
			assets: 'assets/',
			vendor: grunt.file.readJSON('.bowerrc').directory + '/'
		},
		files: {
			get config() {
				return project.paths.config + '*.js';
			},
			grunt: 'Gruntfile.js',
			js: ['js/*.js'],
			scss: ['scss/nodes.scss']
		},
		pkg: grunt.file.readJSON('package.json')
	};

	// Load Grunt configurations and tasks
	require('load-grunt-config')(grunt, {
		configPath: require('path').join(process.cwd(), project.paths.config),
		data: project,
		jitGrunt: {
			staticMappings: {
				useminPrepare: 'grunt-usemin'
			}
		}
	});

};