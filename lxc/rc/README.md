# RC Folder

This folder contains the modified scripts that run into the container. These scripts are `rc.S`, `rc.M`, `rc.6` and `rc.inet1`. The folder contains the associated patches too. The patches are already included in the `lxc-slackware` file.

The command to create the patch files is:

```
diff -u rc.<original> rc.<modified> > rc.<script>.patch
```
