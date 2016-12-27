# Admin panel, build easy customizable admin features for your app!
[![Language](https://img.shields.io/badge/Swift-3-brightgreen.svg)](http://swift.org)
[![Build Status](https://travis-ci.org/nodes-vapor/admin-panel.svg?branch=master)](https://travis-ci.org/nodes-vapor/admin-panel)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/nodes-vapor/admin-panel/master/LICENSE)
# Features
 - Admin user system with roles
 - Welcome mails
 - Reset password
 - Dashboard with easy graphs
 - SSO logins
 
![image](https://cloud.githubusercontent.com/assets/1279756/21502899/83ff79dc-cc53-11e6-8222-40bfa773d361.png)

#Installation
Update your `Package.swift` file.
```swift
.Package(url: "https://github.com/nodes-vapor/admin-panel", majorVersion: 0)
```


#### Config
Create config adminpanel.json

```
{
    "name": "Sandbox2",
    "unauthorizedPath": "/admin/login",
    "loginSuccessPath": "admin/dashboard",
    "loadRoutes": true,
    "profileImageFallbackUrl": "https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg",
    "welcomeMailViewPath": "Emails/welcome",
    "resetPasswordViewPath": "Emails/reset-password"
}


```

### main.swift
```
import AdminPanel
```

And add provider
```
try drop.addProvider(AdminPanel.Provider.self)
```

Either copy the views in or change the folder to read the views from, fx
```
drop.view = LeafRenderer(
    viewsDir: Droplet().workDir + "/Packages/AdminPanel-0.2.0/Sources/AdminPanel/Resources/Views"
)
```
### Seed data
```
vapor run admin-panel:seed
```

### Dependencies
https://github.com/nodes-vapor/storage

### UI package

#### Prerequisites

- node.js > v4.0
- npm > v3.0
- bower > 2.0

#### Setup

- Copy the files from `Packages/AdminPanel-X.Y.Z/Sources/AdminPanel/gulp` to the root of your project
- Copy the files from `Packages/AdminPanel-X.Y.Z/Sources/AdminPanel/Resources/Assets` to the `Resources` folder in your project
- Copy the files from `Packages/AdminPanel-X.Y.Z/Sources/AdminPanel/Public/favicon.ico` and the `favicon` folder to the `Public` folder in your project
- Run `npm install` > `bower install` > `gulp build`

#### Theming

- Update variables in the `_variables.scss` file located in `/Resources/Assets/Scss` (ie. `$primary-color`)
- Compile the styles by running `gulp build`

#### JavaScript

Put your JavaScript files in `/Resources/Assets/Js` - if you need specific js for a specific page- place this file in the `Pages` subfolder.
 
When compiling, all files *not* in `Pages` will be concatinated and minified. Page specific js is only minified.

#### Read more

Github: https://github.com/nodes-frontend/nodes-ui

Doc: https://nodes-frontend.github.io/nodes-ui/
