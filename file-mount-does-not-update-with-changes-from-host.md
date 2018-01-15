# 修改本地文件无法同步到container
https://github.com/moby/moby/issues/15793#issuecomment-210569321  
把一个文件作为volume挂载到容器，修改本地文件后，容器里的文件并被同步修改！
```
I bet I know what's happening here...

If you are using some editor like vim, when you save the file it does not save the file directly, 
rather it creates a new file and copies it into place. This breaks the bind-mount, which is based on inode. 
Since saving the file effectively changes the inode, changes will not propagate into the container.
When the container is restarted the new inode.
If you edit the file in place you should see changes propagate.

This is a known limitation of file-mounts and is not fixable.

Does this accurately describe the issue?
```
## solution  
After reading this, I guess if I type set noswapfile, I might be able to continue using vim.   
Maybe Sublime Text has a similar option ?
