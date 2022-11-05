This collection of PowerShell scripts started as things that I wished to automate for
myself. I've decided to create this repository so that in the event of loss of my
laptop or hard disk I would be able to recreate my native command aliases. The 'set_ps_profile.ps1'
script, when ran in place in this cloned repository will copy all of the PowerShell scripts
into the "C:/Program Files" folder and append them to the PowerShell "Profile.ps1" profile
in the "$PSHOME" directory. If you should choose to use these scripts, you may wish to
alter the "set_ps_profile.ps1" script to copy these files to a different location, and
likewise alter the '$PSHOME' location to $PROFILE instead if You'd rather not apply aliases to
every users profile. Additionally, the 'set_ps_profile.ps1' script MUST be ran as Administrater or
it will throw an error.

--Will Morris
