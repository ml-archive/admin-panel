const elixir = require('laravel-elixir');

/*
 |--------------------------------------------------------------------------
 | Elixir Asset Management
 |--------------------------------------------------------------------------
 |
 | Elixir provides a clean, fluent API for defining some basic Gulp tasks
 | for your Laravel application. By default, we are compiling the Sass
 | file for our application, as well as publishing vendor resources.
 |
 */

// Folder pahts
Elixir.config.appPath         = "../App";
Elixir.config.publicPath      = "../Public";
Elixir.config.assetsPath      = "Resources/Assets";
Elixir.config.viewsPath       = "Resources/Views";

// (S)CSS options
Elixir.config.css.sass.folder = "Sass"

// JavaScript options
Elixir.config.js.folder       = "Js"


// Mix it up!
elixir(mix => {
    mix.sass("app.scss")
       .scripts([
           "../../../bower_components/jquery/dist/jquery.js",
           "../../../bower_components/bootstrap-sass/assets/javascripts/bootstrap.js",
           "../../../bower_components/Chart.js/Chart.js",
           "../../../bower_components/nodes-ui/js/nodes.compiled.js",
           "app.js"
       ])
});
