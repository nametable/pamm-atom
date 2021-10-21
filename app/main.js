// Electron modules
// var for consistency with the rest of the project
var {app,BrowserWindow,dialog,ipcMain} = require('electron');
// electron remote init
require('@electron/remote/main').initialize()

//checking nodejs modules here
try{
	require('semver');
}catch(e){
	app.on('ready', () => {
			dialog.showMessageBox({
			title:"error!",
			type:"info",
			message:"Dependencies are missing. Please re-run the installer"
		},() => {
			app.quit();
		})
	})
	
}
// Node.js modules
var fs = require('fs');
var path = require('path');
var semver = require('semver');
var url = require('url');
var params = {
	info: {},
	context: 'client',
	devmode: false,
	install: ""
};
global['params'] = params;
// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the javascript object is GCed.
var mainWindow = null;
// Quit when all windows are closed.
app.on('window-all-closed', function() {
	if (process.platform != 'darwin')
		app.quit();
});
//Quit when instructed to
ipcMain.on('closePamm', function() {
	console.log('closing pamm');
	app.quit();
})
// This method will be called when atom-shell has done everything
// initialization and ready for creating browser windows.
app.on('ready', function() {
	console.log('Reading package.json');
	fs.readFile(__dirname + path.sep + 'package.json', {
		encoding: 'utf8'
	}, function(err, data) {
		if (err) throw err;
		params.info = JSON.parse(data);
		checkEngine();
		console.log('Parsing arguments');
		var argv = process.argv;
		for (var i = 0; i < argv.length; ++i) {
			var arg = argv[i];
			if (arg.indexOf('pamm://') === 0) {
				if (arg.slice(-1) === '/') {
					arg = arg.substring(0, arg.length - 1)
				}
				var values = arg.substring(7).split('/');
				if (values.length === 1) {
					params.install = values[0];
				} else if (values[0] === "install") {
					params.install = values[1];
				} else {
					console.log("Unsupported verb '" + values[0] + "' in '" + arg + "'");
				}
			} else if (arg === 'devmode') {
				params.devmode = true;
			} else if (arg === 'offline') {
				params.offline = true;
			} else if (arg === 'server') {
				params.context = 'server';
			}
		}
		console.log('Mod to install: ' + (params.install ? params.install : 'none'));
		console.log('DevMode: ' + params.devmode);
		// Create the browser window.
		console.log('Instanciate BrowserWindow');
		mainWindow = new BrowserWindow({
			width: 1280,
			height: 720,
			icon: path.join(__dirname, 'assets/img/pamm.png'),
			webPreferences: {
				nodeIntegration: true,
				contextIsolation: false,
				enableRemoteModule: true
			}
		});
		require("@electron/remote/main").enable(mainWindow.webContents)
		//mainWindow.setMenu(null);
		// and load the index.html of the app.
		console.log('Load main page');
		mainWindow.loadURL('file://' + __dirname + '/index.html');
		mainWindow.loadURL(url.format({
			pathname: path.join(__dirname, 'index.html'),
			protocol: 'file:',
			slashes: true
		}));
		// Open chromium devtool debugger
		if (params.devmode) {
			mainWindow.openDevTools();
		} else {
			//get rid of all those menu things
			mainWindow.setMenu(null);
		}
		// Emitted when the window is closed.
		mainWindow.on('closed', function() {
			// Dereference the window object, usually you would store windows
			// in an array if your app supports multi windows, this is the time
			// when you should delete the corresponding element.
			mainWindow = null;
		});
	});
});
var checkEngine = function() {
	var current = process.versions['electron'];
	var expected = params.info.engines['electron'];
	if (!semver.satisfies(current, expected)) {
		dialog.showMessageBox({
			type: "warning",
			buttons: ["Quit"],
			title: "Incompatible version",
			message: "The Electron version currently used to run PAMM is outdated and will be unable to run as expected.\n\nPlease reinstall PAMM or upgrade Electron manually."
		});
		app.quit();
	}
}
