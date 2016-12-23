'use strict';

var path = require('path');
var fs = require('fs');

var gulp = require('gulp');
var mainBowerFiles = require('main-bower-files');

var uglify = require('gulp-uglify');
var concatSourcemaps = require('gulp-concat-sourcemap');
var concat = require('gulp-concat');
var gulpIf = require('gulp-if');

var sass = require('gulp-sass');
var postcss	= require('gulp-postcss');
var sourcemaps = require('gulp-sourcemaps');
var autoprefixer = require('autoprefixer');
var cssmin = require('gulp-cssmin');
var rename = require('gulp-rename');

var NODES_BOWER_PACKAGES = require('./bower_components/nodes-ui/bower.json');
var PROJECT_BOWER_PACKAGES = require('./bower.json');
var IGNORED_BOWER_PACKAGES = [
    "!**/bower_components/bootstrap/dist/js/bootstrap.js",
    "!**/bower_components/blueimp-tmpl/js/tmpl.js"
];

gulp.task('vendor-scripts', function() {
    
    var MERGED_PKGS = PROJECT_BOWER_PACKAGES;
    
    var jsFileName = 'vendor.js';
    
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
    
    return gulp.src(mainBowerFiles({filter: filterFiles}))
        .pipe(concat(jsFileName, {sourcesContent: true}))
        .pipe(uglify()).on('error', console.error.bind(console))
        .pipe(gulp.dest('./Public/js'));
    
});

gulp.task('project-scripts', function() {
    var jsFileName = 'project.js';
    
    var jsSources = [
        './Resources/Assets/Js/**/*.js',
        '!./Resources/Assets/Js/Pages/**/*.js'
    ];
    
    return gulp.src(jsSources)
        .pipe(concat(jsFileName))
        .pipe(uglify()).on('error', console.error.bind(console))
        .pipe(gulp.dest('./Public/js'));
    
});

gulp.task('project-pages-scripts', function() {
        
    var jsSources = [
        './Resources/Assets/Js/Pages/**/*.js'
    ];
    
    return gulp.src(jsSources)
        .pipe(uglify()).on('error', console.error.bind(console))
        .pipe(gulp.dest('./Public/js'));
});

gulp.task('styles', function() {
    
    var scssSource = [
        './Resources/Assets/Scss/main.scss'
    ];
    
    return gulp.src(scssSource)
        .pipe(sourcemaps.init())
        .pipe(sass({
            outputStyle: 'compressed',
            includePaths: ['bower_components', 'node_modules']
        })).on('error', console.error.bind(console))
        .pipe(postcss([
            autoprefixer({
                browsers: ['last 2 versions', 'ie >= 10']
            })
        ]))
        .pipe(sourcemaps.write())
        .pipe(rename('styles.css'))
        .pipe(gulp.dest('./Public/css'));
});

gulp.task('watch', function() {
    gulp.watch('./bower_components/**/*.js', ['vendor-scripts']);
    gulp.watch([
        './Resources/Assets/Js/**/*.js',
        '!./Resources/Assets/Js/Pages/**/*.js'
    ], ['project-scripts']);
    gulp.watch('./Resources/Assets/Js/Pages/**/*.js', ['project-pages-scripts']);
    gulp.watch(['./bower_components/**/*.scss', './Resources/Assets/Scss/**/*.scss'], ['styles']);
});

// Convenience tasks
gulp.task('build-js', ['vendor-scripts', 'project-scripts', 'project-pages-scripts']);
gulp.task('build-css', ['styles']);
gulp.task('build', ['build-js', 'build-css']);

gulp.task('default', ['build', 'watch']);