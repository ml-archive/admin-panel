# Admin panel, build easy customizable admin features for your app!
[![Language](https://img.shields.io/badge/Swift-3-brightgreen.svg)](http://swift.org)
[![Build Status](https://travis-ci.org/nodes-vapor/admin-panel.svg?branch=master)](https://travis-ci.org/nodes-vapor/admin-panel)
[![codecov](https://codecov.io/gh/nodes-vapor/admin-panel/branch/master/graph/badge.svg)](https://codecov.io/gh/nodes-vapor/admin-panel)
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
.Package(url: "https://github.com/nodes-vapor/admin-panel.git", majorVersion: 0)
```


#### Config
Create config adminpanel.json

```
{
    "name": "Nodes Admin Panel",
    "unauthorizedPath": "/admin/login",
    "loginSuccessPath": "admin/dashboard",
    "loadRoutes": true,
    "profileImageFallbackUrl": "https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg",
    "welcomeMailViewPath": "Emails/welcome",
    "resetPasswordViewPath": "Emails/reset-password",
    "autoLoginFirstUser": true,
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
    ],
}

```

Create config mail.json
```
{
    "smtpHost": "smtp.mailgun.org",
    "smtpPort": "465",
    "user": "",
    "password": "",
    "fromEmail": ""
}
```

Make sure to have config app.json setup
```
{
    "name": "MY-PROJECT",
    "url": "0.0.0.0:8080"
}

```
The url here will be used as redirect link in invite emails fx.


### main.swift
```
import AdminPanel
```

And add provider (before defining routes, but after defining cache driver)
```
try drop.addProvider(AdminPanel.Provider.self)

/// ... routes goes here

```
### Seed data
```
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
```
drop.view = LeafRenderer(
    viewsDir: Droplet().workDir + "/Packages/AdminPanel-0.5.4/Sources/AdminPanel/Resources/Views"
)
```
