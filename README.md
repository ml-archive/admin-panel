# admin-panel

![Login screen](https://user-images.githubusercontent.com/944158/63353860-b0fc1580-c363-11e9-881c-fec19874b4c0.png)

![Successful login](https://user-images.githubusercontent.com/944158/63353912-cbce8a00-c363-11e9-9e06-c3856da5410e.png)

![Manage users](https://user-images.githubusercontent.com/944158/63353941-ddb02d00-c363-11e9-94ee-1411ae102645.png)

## Features

### Confirm Modal

Admin Panel includes a generic confirmation modal for links, out of the box. Using HTML data attributes on `<a>`-tags the modal can be configured in different ways. Just add a data attribute to your link and you're all set.

Triggering the modal will append a HTML-element form to the DOM, containing title, text, confirm button and dismiss button.

By default confirm submits the form and dismiss will remove the HTML-element from the DOM

**Basic usage**

```HTML
<a href="#" data-confirm="true">Open modal</a>
```

**Data Attributes**

|Attribute|Description|example|
|---------|-----------|-------|
|data-confirm|Initialize the modal|`data-confirm="true"`|
|data-title|Sets the title of the modal|`data-title="Please confirm"`|
|data-text|Sets the text of the modal|`data-text="Are you sure you want to continue?"`|
|data-button|Sets bootstrap css selector for the confirm button|`data-button="danger"` _[primary,secondary,success,danger,warning,info,light,dark]_|
|data-confirm-btn|Set the text label on the "confirm"-button|`data-confirm-btn="Yes"`|
|data-dismiss-btn|Set the text label on the "dismiss"-button|`data-confirm-btn="No"`|

**Override default behavior**

```javascript
// Override modal confirm action
modalConfirmation.actions.confirm = function(event) {
    alert("Confirmed");
}

// Overríde modal dismiss action
modalConfirmation.actions.dismiss = function(event) {
    alert("Dismissed");
}
```

### Leaf tags

Admin panel comes with a variety of leaf tags for generating certain HTML/js elements

#### #adminPanel:avatarURL
Use user image or fallback to [Adorable avatars](http://avatars.adorable.io/)

|Parameter|Type|Description|
|---------|----|-----------|
|`email`|String| _user's email_|
|`url`|String|_image url_|

Example usage
```
<img src="#adminPanel:avatarURL(user.email, user.avatarURL)" alt="Profile picture" class="img-thumbnail" width="40">
```
