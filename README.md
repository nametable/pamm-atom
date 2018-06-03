# PA Mod Manager (electron edition)

Original Windows version : https://forums.uberent.com/threads/rel-pa-mod-manager-v4-0-3.50726/

Original Linux and Mac OS X version : https://forums.uberent.com/threads/rel-raevns-pa-mod-manager-for-linux-and-mac-os-x-version-4-0-2.50958/

By using electron, this version should be able to run on every platform supported by Planetary Annihilation at once.
This is a port of the Windows version which already uses an HTML engine.

## Installation

Download this project and uncompress it : 
https://github.com/pamods/pamm-atom/archive/stable.zip

Windows x64 users should run the install.bat file located in the root of this project. 
This will install PAMM into your PA user data, create a desktop shortcut, and launch PAMM.

For other systems:

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

Then execute `Electron.app` (or `electron` on Linux, and `electron.exe` on Windows), and Electron will start PAMM.