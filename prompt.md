While maintaining all the existing features, I want this to be added:

If the clipboard contains a url (let's say <url>), ask the user for the title of the link (let's say <title>) and insert this:

```md
[<title>](<url>)
```

If the user doesn't give you a title and just presses enter, just pritn the url:

```md
<url>
```

You should end up in the same mode as you were originally. If in insert mode, the cursor should be right after ) so that the user can continue typing.

Plan first and then implement.
Interview me if necessary.
