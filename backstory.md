honestly i was just very bored and didn't want to go to bed so i wrote this  
## pre-development   
i was on the c/c++ help server on discord   
trying to help people then someone ran the /howto Choosing an IDE/Editor command  
i noticed micro was on a the terminal editors list i went to check it out for fun   
then i notice it had autopairs which were something i hated from vscode(because they were so bad)   
i then realised how helpful they can be   
## development
i ddg'd "vim brackets" hoping for a plugin but i found a stackoverflow question with an answer that was in vanilla vim   
https://stackoverflow.com/questions/21316727/automatic-closing-brackets-for-vim  
the answer was pretty barebones it had weird cursor movement and freezing that was very annoying   
but then i said since the answer is so close to what i want why not try to improve it  and learn plugin development on the way 
### the problems   
1. when writing {;} the cursor freezes (also happeneding with expanding the {} pair)   
2. when expanding the {} the cursor moves 2 times  and also switches to normal mode 
the first issue was very easy to fix by mapping the semicolon/return key  
the second issue took 1.5~ days of searching throught (n)vim docs   
i settled on not relying on any key presses and fully using the nvim-api  
this made the cursor only move on command and stay in insert mode (important for statuslines)
### what to learn 
1. when writing something that needs low-level control never rely on highlevel-builtins,  
like in my case the problem was already solved i just need more control to make it seemless
2. never do logic in your head alone, always use paper as it makes every variable/step much easier to access,  
this would have probably made the problem solved in 2 days instead of 3
3. never to rush to test code, it's always a good idea to reread the code at least once before testing it
4. trying to make something perfect may not always be a bad idea
## the nvim-autopairs situation
now during the first 2 days i went to check nvim-autopairs to see if they have resolved this issue
and they haven't and i found a good solution to give to nvim-autopairs using only use keys

i plan to add custom pairs and endwise to my plugin to make the plugin usable for most languages   
with the goal of fully working in insert mode and not moving the cursor twice

## the end
so yeah that's the story of how i hacked in an autopairs plugin in 3 days
