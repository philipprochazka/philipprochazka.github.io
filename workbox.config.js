const swPrecache = { 
    globPatterns: [       
'https://use.fontawesome.com/releases/v6.3.0/js/all.js',
'https://fonts.googleapis.com/css?family=Roboto:300,300italic,700,700italic',
'https://fonts.googleapis.com/css?family=Saira+Extra+Condensed:500,700',
'https://fonts.googleapis.com/css?family=Muli:400,400i,800,800i',
'dist/**.html',
'dist/**/*.css',
'dist/**/*.js',
'dist/**.json',
'dist/**.txt',
'dist/images/*',
    ],
    root: 'dist',
    stripPrefix: 'dist/',
    directoryIndex: 'index.html',
    navigateFallback: 'index.html',
    runtimeCaching: [],
  }
  
  module.exports = swPrecache