# PA Mod Manager (electron edition)

Original Windows version : https://forums.uberent.com/threads/rel-pa-mod-manager-v4-0-3.50726/

Original Linux and Mac OS X version : https://forums.uberent.com/threads/rel-raevns-pa-mod-manager-for-linux-and-mac-os-x-version-4-0-2.50958/

By using electron, this version should be able to run on every platform supported by Planetary Annihilation at once.
This is a port of the Windows version which already uses an HTML engine.

## Installation

Download this project and uncompress it : 
https://github.com/pamods/pamm-atom/archive/stable.zip

Windows should run the install.bat file located in the root of this project. Windows 7 Users must have PowerShell>=4: [Download](https://www.microsoft.com/en-us/download/details.aspx?id=54616) (Win7AndW2K8R2-KB3191566-x64.zip), Windows 8 users must upgrade to Windows 8.1 and Windows 8.1 and 10 users do not have to download anything.
This will install PAMM into your PA user data, create a desktop shortcut, and launch PAMM.

Mac/Linux users should use install.sh

You must have a 64 bit system for the installation scripts; you would be crazy to play PA on a 32 bit system.

## Manual install

Download the electron release for your platform and uncompress it: 
https://github.com/electron/electron/releases

Or put the `app` folder under electron's resources directory (on OS X it is `Electron.app/Contents/Resources/`, and on Linux and Windows it is `resources/`), like this:

On Mac OS X:

```text
electron/Electron.app/Contents/Resources/app/
├── package.json
├── main.js
└── index.html
```

On Windows and Linux:

```text
electron/resources/app
├── package.json
├── main.js
└── index.html
```

You must then install the dependencies of PAMM. If you have node installed, run `npm install --production` in the directory with package.json in it. If you do not, we've already prepared a zip with node_modules. Unzip that such that your directory structure looks like this.

```text
electron/resources/app or electron/Electron.app/Contents/Resources/app/
├── node_modules
├── package.json
├── main.js
└── index.html
```

Then execute `Electron.exe` , `Electron.app` or `Electron` depending on your OS and Electron will start PAMM.
