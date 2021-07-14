const gulp        = require('gulp');
const browserSync = require('browser-sync').create();
const sass        = require('gulp-sass')(require('sass'));
//const cleanCSS    = require('gulp-clean-css'); 

// Compile sass into CSS & auto-inject into browsers
gulp.task('sass', function() {
    return gulp.src("app/assets/scss/*.scss")
        .pipe(sass())
        .pipe(gulp.dest("app/assets/css"))
        .pipe(browserSync.stream());
});

// mangle to CSS to make the package smaller
//gulp.task('', functio() => {
//    return gulp.src("app/assets/*.css")
//        .pipe
//})

// Static Server + watching scss/html files
gulp.task('serve', gulp.series('sass', function() {

    browserSync.init({
        server: "./app/"
    });

    gulp.watch("app/assets/scss/*.scss", gulp.series('sass'));
    gulp.watch("app/*.html").on('change', browserSync.reload);
}));


// default task is to serve this porject via browser-synv
gulp.task('default', gulp.series('serve'));

// build task builds and minify/uglify the css
gulp.task('build', gulp.series('sass'));