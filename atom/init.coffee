# Your init script
#
# Atom will evaluate this file each time a new window is opened. It is run
# after packages are loaded/activated and after the previous editor state
# has been restored.
#
# An example hack to log to the console when each text editor is saved.
#
# atom.workspace.observeTextEditors (editor) ->
#   editor.onDidSave ->
#     console.log "Saved! #{editor.getPath()}"
atom.workspace.observePanes (pane) ->
  console.log(pane)

fixTreeView = ->
  treeViewResizer = document.querySelector(".tree-view-resizer")
  if treeViewResizer? then treeViewResizer.style.display = null
  setTimeout(fixTreeView, 600000)

setTimeout(fixTreeView, 600)

# require('electron').webFrame.setZoomFactor(1.5)
