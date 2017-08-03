# Admin Panel ✍️
[![Swift Version](https://img.shields.io/badge/Swift-3.1-brightgreen.svg)](http://swift.org)
[![Vapor Version](https://img.shields.io/badge/Vapor-2-F6CBCA.svg)](http://vapor.codes)
[![Linux Build Status](https://img.shields.io/circleci/project/github/nodes-vapor/admin-panel.svg?label=Linux)](https://circleci.com/gh/nodes-vapor/admin-panel)
[![macOS Build Status](https://img.shields.io/travis/nodes-vapor/admin-panel.svg?label=macOS)](https://travis-ci.org/nodes-vapor/admin-panel)
[![codebeat badge](https://codebeat.co/badges/52c2f960-625c-4a63-ae63-52a24d747da1)](https://codebeat.co/projects/github-com-nodes-vapor-admin-panel)
[![codecov](https://codecov.io/gh/nodes-vapor/admin-panel/branch/master/graph/badge.svg)](https://codecov.io/gh/nodes-vapor/admin-panel)
[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=https://github.com/nodes-vapor/admin-panel)](http://clayallsopp.github.io/readme-score?url=https://github.com/nodes-vapor/admin-panel)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/nodes-vapor/admin-panel/master/LICENSE)


Build easy customizable admin features for your app!

## Features
 - Admin user system with roles
 - Welcome mails
 - Reset password
 - Dashboard with easy graphs
 - SSO logins
 
![image](https://cloud.githubusercontent.com/assets/1279756/21502899/83ff79dc-cc53-11e6-8222-40bfa773d361.png)


## 📦 Installation

Update your `Package.swift` file.
```swift
.Package(url: "https://github.com/nodes-vapor/admin-panel.git", majorVersion: 1)
```


## Getting started 🚀

### Configs
Create config `adminpanel.json`

```json
{
    "name": "Nodes Admin Panel",
    "unauthorizedPath": "/admin/login",
    "loginSuccessPath": "admin/dashboard",
    "loadRoutes": true,
    "loadDashboardRoute": true,
    "profileImageFallbackUrl": "https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg",
    "welcomeMailViewPath": "Emails/welcome",
    "resetPasswordViewPath": "Emails/reset-password",
    "autoLoginFirstUser": false,
    "ssoRedirectUrl": "https://mysso.com",
    "ssoCallbackPath": "/admin/ssocallback",
    "roles": [
        {
            "title": "Super admin",
            "slug": "super-admin",
            "is_default": false
        },
        {
            "title": "Admin",
            "slug": "admin",
            "is_default": false
        },
        {
            "title": "User",
            "slug": "user",
            "is_default": true
        }
    ]
}

```

Create config `mail.json`
```json
{
    "smtpHost": "smtp.mailgun.org",
    "smtpPort": "465",
    "user": "",
    "password": "",
    "fromEmail": ""
}
```

Make sure to have config `app.json` setup
```json
{
    "name": "MY-PROJECT",
    "url": "0.0.0.0:8080"
}

```
The url here will be used as redirect link in invite emails fx.


### main.swift
```swift
import AdminPanel
```

And add provider (before defining routes, but after defining cache driver)
```swift
try drop.addProvider(AdminPanel.Provider.self)

/// ... routes goes here

```
### Seed data
Add the seeder command to your `main.swift`
```swift
drop.commands.append(AdminPanel.Seeder(drop: drop))
```

And then run the command in your terminal (remember to build the project first)
```swift
vapor run admin-panel:seeder
```

### UI package

#### Prerequisites

- node.js > v4.0
- npm > v3.0
- bower > 2.0

With brew
```
brew install node
brew install npm
brew install bower
npm install -g gulp
```

#### Setup

- Copy the files from `Packages/AdminPanel-X.Y.Z/Sources/AdminPanel/gulp` to the ROOT of your project
- Copy the files from `Packages/AdminPanel-X.Y.Z/Sources/AdminPanel/Resources` to the `Resources` folder in your project
- Copy the files from `Packages/AdminPanel-X.Y.Z/Sources/AdminPanel/Public/favicon.ico` and the `favicon` folder to the `Public` folder in your project
- Run `npm install` > `bower install` > `gulp build`

#### Read more

Wiki: https://github.com/nodes-vapor/admin-panel/wiki

Github: https://github.com/nodes-frontend/nodes-ui

Doc: https://nodes-frontend.github.io/nodes-ui/

#### Using views from packages (for development)
```swift
drop.view = LeafRenderer(
    viewsDir: Droplet().workDir + "/Packages/AdminPanel-0.5.4/Sources/AdminPanel/Resources/Views"
)
```


## 🏆 Credits

This package is developed and maintained by the Vapor team at [Nodes](https://www.nodesagency.com).
The package owner for this project is [Steffen](https://github.com/steffendsommer).


## 📄 License

This package is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
