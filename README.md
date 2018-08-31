# admin-panel

A description of this package.


#### Confirm Modal

Admin Panel includes a generic confirmation modal for links, out of the box. Using HTML data attributes on `<a>`-tags the modal can be configured in diffenrent ways. Just add a data attribute to your link and you're all set.

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
