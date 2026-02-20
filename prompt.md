Now, add this capability on top of what exists:

If the content of the clipboard is an image, create a markdown image like this:

If the name of the current buffer is file.md, the images should be stored in the folder file.assets. If that folder doesn't exist already create it.
Ask the user for the name of the image file. If he just presses enter with no name, create a unique ID for the file name. 
prefix the file name with 'img-'.
Use the image name as the title of the image like this:

```markdown
[img-<name without extension>](./<buffer name without extension>.assets/img-<name>.png)
```

As seen, the  path to the image should be relative.
After this is done, you should be in normal mode and the cursor should be right after [ so the user can delete and replace the imge title in he wants.
The plugin should have an extension for changing image extension. But, the defualt is .png.

Make a plan and then implement it. 
Interview me if necessary.
