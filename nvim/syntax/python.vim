if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn keyword pythonSelf self cls
syn keyword pythonExClass ToruError ToruErr
hi def link pythonSelf Identifier
hi def link pythonExClass Structure
