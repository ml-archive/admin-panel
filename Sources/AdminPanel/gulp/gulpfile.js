'use strict';

var path = require('path');
var fs = require('fs');

var gulp = require('gulp');
var mainBowerFiles = require('main-bower-files');

var sass = require('gulp-sass');
var autoprefixer = require('autoprefixer');
var postcss = require('gulp-postcss');
var cssmin = require('gulp-cssmin');

var uglify = require('gulp-uglify');
var concatSourcemaps = require('gulp-concat-sourcemap');
var concat = require('gulp-concat');
var gulpIf = require('gulp-if');

var NODES_BOWER_PACKAGES = require('./bower_components/nodes-ui/bower.json');
var PROJECT_BOWER_PACKAGES = require('./bower.json');
var IGNORED_BOWER_PACKAGES = [
    "!**/bower_components/bootstrap/dist/js/bootstrap.js",
    "!**/bower_components/blueimp-tmpl/js/tmpl.js"
];

gulp.task('vendor-scripts', function() {
    
    var MERGED_PKGS = PROJECT_BOWER_PACKAGES;
    
    for(var pkg in NODES_BOWER_PACKAGES.dependencies) {
        if(!PROJECT_BOWER_PACKAGES.dependencies.hasOwnProperty(pkg)) {
            MERGED_PKGS.dependencies[pkg] = NODES_BOWER_PACKAGES.dependencies[pkg];
        }
    }
    
    try {
        fs.writeFileSync('bower.json', JSON.stringify(MERGED_PKGS, null, '\t'));
    } catch(err) {
        return console.log('Error updating project bower.json file!', err);
    }
    
    var filterFiles = ['**/*.js', '!**/*.js.map'].concat(IGNORED_BOWER_PACKAGES);
    var jsFileName = 'vendor.js';
    console.log('AAA', mainBowerFiles({
        filter: filterFiles
    }))
    
    return gulp.src(mainBowerFiles({
        filter: filterFiles
    }))
        .pipe(concat(jsFileName, {sourcesContent: true}))
        .pipe(uglify()).on('error', console.error.bind(console))
        .pipe(gulp.dest('./Resources/Assets/Js'));
    
});