################  Musume Piece  ###############################################
#                                                                             #
## Original Script Detail                                                     #
### Introduction                                                              #  
# Anti Advertise Script                                                       #
# SadSalman <-> salman.mehmood@gmail.com                                      #
# Version No: 0.2                                                             #
### Features:                                                                 #
# * Sets a 2 Minute Channel ban on user who writes any of the                 #
#   defined words [ Wasnt working!]                                           #
# * Doesn't ban users with +o OR +f flags [ took this option off ]            #
# * Logs ALL user/op messages containing the defined words [ Not needed ]     #
# * Strips Character Codes from Messages                                      #
###############################################################################

###############################################################################
# Forbiden Words 0.1							      #
# About the scripts						              #
# Anti Advertise & Anti Badword Script					      #	
# Modified BY - ERROR | Bug Reports: koustab@gmail.com                        #
###############################################################################

###############################################################################
# New Features Added :                                                        #
###############################################################################
# * 9 Ban types mask                                                          # 
# * To active this script in a channel just use .chanset #channelname +forbid #
# * Two diff ban time added.                                                  #   
# * Two diff kick reason added.                                               #    
# * Wont kick channel ops                                                     #
# * Channel Notice added                                                      #  
# * Channel Action added                                                      #
###############################################################################

###### To Do ##################################################################
# * exampt Words                                                              #
# * Flags to exampt                                                           #
# * Privet Message scanner.                                                   #
###############################################################################


## Channel flag.

setudef flag forbid

###############################################################################
#                                                                             #
#                            script configuration                             #
#                                                                             #
###############################################################################



### Set Advertising Words that you want the Bot to Kick.

set advwords { 
  "https://"
  "http://" 
  "http" 
  "https" 
}

### Set Bad Words that you want the Bot to Kick.
set badwords {
  "fuck"
  "gay"
  "rape"
  "badword2"  
}




### Set Your Advert Ban Reason
set advreason "Advertisement Not Allowed"

#Set Your Badword Kick Reason
set badreason "Swearing Not allowed."


# Set the banmask type to use in banning the User who uses badwords.
# Currently BAN Type is set to 1 (*!*@some.domain.com),
# BAN Types are given below;
# 1 - *!*@some.domain.com 
# 2 - *!*@*.domain.com
# 3 - *!*ident@some.domain.com
# 4 - *!*ident@*.domain.com
# 5 - *!*ident*@some.domain.com
# 6 - *nick*!*@*.domain.com
# 7 - *nick*!*@some.domain.com
# 8 - nick!ident@some.domain.com
# 9 - nick!ident@*.host.com
set bantype "3"



### Set Ban Time for advert bans in minutes. Example for 1 hour just put 60
set adbantime 1

### Set Ban Time for badwords bans in minutes. Example for 1 hour just put 60
set badbantime 1


#Set the Users Mode you want to Exempt [ not working too ]
#The Bot will not kick the user who had the modes you will define below
#set forbiduser "+o"

#################################################################################################
## PLEASE DONT TOUCH BELLOW YOU MAY BREAK IT OR MAKE    SOMETHING  REALLY NICE BY ACCDIENT ;P ###                                                                              
#                                       =)                                                      #                                                                                                        =)      
#################################################################################################

### Borrowed from awyeahs tcl scripts (www.awyeah.org) ###
## awyeah said: Thanks to user and ppslim for this control code removing filter
proc ccodes:filter {str} {
  regsub -all -- {\003([0-9]{1,2}(,[0-9]{1,2})?)?|\017|\037|\002|\026|\006|\007} $str "" str
  return $str
}

## Set a ban type
proc forbidword:banmask {uhost nick} {
 global bantype
  switch -- $bantype {
   1 { set banmask "*!*@[lindex [split $uhost @] 1]" }
   2 { set banmask "*!*@[lindex [split [maskhost $uhost] "@"] 1]" }
   3 { set banmask "*!*$uhost" }
   4 { set banmask "*!*[lindex [split [maskhost $uhost] "!"] 1]" }
   5 { set banmask "*!*[lindex [split $uhost "@"] 0]*@[lindex [split $uhost "@"] 1]" }
   6 { set banmask "*$nick*!*@[lindex [split [maskhost $uhost] "@"] 1]" }
   7 { set banmask "*$nick*!*@[lindex [split $uhost "@"] 1]" }
   8 { set banmask "$nick![lindex [split $uhost "@"] 0]@[lindex [split $uhost @] 1]" }
   9 { set banmask "$nick![lindex [split $uhost "@"] 0]@[lindex [split [maskhost $uhost] "@"] 1]" }
   default { set banmask "*!*@[lindex [split $uhost @] 1]" }
   return $banmask
  }
}


## Binding all Public Messages to our Process
bind pubm - * filter_ad

## Starting Process - adverts
proc filter_ad {nick uhost handle channel args} {
 global advwords advreason botnick chname bantime adbantime
  if {([lsearch -exact [channel info $channel] {+forbid}] != -1)}  {
  set args [ccodes:filter $args]
  set handle [nick2hand $nick]
  set banmask "[forbidword:banmask $uhost $nick]" 
    foreach advword [string tolower $advwords] {
     if {[string match *$advword* [string tolower $args]]}  {
    if {[isop $nick $channel]} {   
     putlog "-Forbiden words- $nick ($handle) with +o flags said $args on $channel"
   } else {
            putquick "MODE $channel +b $banmask"   
            putquick "KICK $channel $nick :$advreason"
            newchanban $channel $banmask $botnick $advreason $adbantime
            putlog "- Nick - $nick - Banmask - $banmask  added to a ban list - Duration - $adbantime minute" 
         }
       }
    }
  }
}

## Starting Process - badwords

bind pubm - * filter_bad

## Starting Process - works
proc filter_bad {nick uhost handle channel args} {
 global badwords badreason botnick chname bantime badbantime
   if {([lsearch -exact [channel info $channel] {+forbid}] != -1)}  {
  set args [ccodes:filter $args]
  set handle [nick2hand $nick]
  set banmask "[forbidword:banmask $uhost $nick]"
    foreach badword [string tolower $badwords] {
     if {[string match *$badword* [string tolower $args]]}  {
     if {[isop $nick $channel]} {
     putlog "-Forbiden words- $nick ($handle) with +o flags said $args on $channel"
    } else {
            putquick "MODE $channel +b $banmask"
            putquick "KICK $channel $nick :$badreason"
            newchanban $channel $banmask $botnick $badreason $badbantime
            putlog "- Nick - $nick - Banmask - $banmask  added to a ban list - Duration - $badbantime minute"

         }
       }
     }
   }
}

### Starting Process - advert words Notice

bind NOTC - * filter_adnotice

proc filter_adnotice {nick uhost handle text channel args} {
global botnick bantype banmask advwords advreason adbantime
  if {([lsearch -exact [channel info $channel] {+forbid}] != -1)}  {
  set args [ccodes:filter $args]
  set handle [nick2hand $nick]
  set banmask "[forbidword:banmask $uhost $nick]"
    foreach advword [string tolower $advwords] {
     if {[string match *$advword* [string tolower $text]]}  {
    if {[isop $nick $channel]} {
     putlog "-Forbiden words- $nick ($handle) with +o flags said $args on $channel"
   } else {
            putquick "MODE $channel +b $banmask"
            putquick "KICK $channel $nick :$advreason"
            newchanban $channel $banmask $botnick $advreason $adbantime
            putlog "- Nick - $nick - Banmask - $banmask  added to a ban list - Duration - $adbantime minutes"
	}
      }
    }
  }
}

### Starting Process - bad words Notice

bind NOTC - * filter_badnotice

proc filter_badnotice {nick uhost handle text channel args} {
global botnick bantype banmask badwords badreason badbantime
  if {([lsearch -exact [channel info $channel] {+forbid}] != -1)}  {
  set args [ccodes:filter $args]
  set handle [nick2hand $nick]
  set banmask "[forbidword:banmask $uhost $nick]"
    foreach badword [string tolower $badwords] {
     if {[string match *$badword* [string tolower $text]]}  {
    if {[isop $nick $channel]} {
     putlog "-Forbiden words- $nick ($handle) with +o flags said $args on $channel"
   } else {
            putquick "MODE $channel +b $banmask"
            putquick "KICK $channel $nick :$badreason"
            newchanban $channel $banmask $botnick $badreason $badbantime
            putlog "- Nick - $nick - Banmask - $banmask  added to a ban list - Duration - $badbantime minute"
        }
      }
    }
  }
}

### Starting Process - bad words action


bind act - * filter_badact

proc filter_badact {nick uhost handle text channel args} {
global botnick bantype banmask badwords badreason badbantime
  if {([lsearch -exact [channel info $channel] {+forbid}] != -1)}  {
  set args [ccodes:filter $args]
  set handle [nick2hand $nick]
  set banmask "[forbidword:banmask $uhost $nick]"
    foreach badword [string tolower $badwords] {
     if {[string match *$badword* [string tolower $text]]}  {
    if {[isop $nick $channel]} {
     putlog "-Forbiden words- $nick ($handle) with +o flags said $args on $channel"
   } else {
            putquick "MODE $channel +b $banmask"
            putquick "KICK $channel $nick :$badreason"
            newchanban $channel $banmask $botnick $badreason $badbantime
            putlog "- Nick - $nick - Banmask - $banmask  added to a ban list - Duration - $badbantime minute"
        }
      }
    }
  }
}

### Starting Process - advert words action

bind act - * filter_adact

proc filter_adact {nick uhost handle text channel args} {
global botnick bantype banmask advwords advreason adbantime
  if {([lsearch -exact [channel info $channel] {+forbid}] != -1)}  {
  set args [ccodes:filter $args]
  set handle [nick2hand $nick]
  set banmask "[forbidword:banmask $uhost $nick]"
    foreach advword [string tolower $advwords] {
     if {[string match *$advword* [string tolower $text]]}  {
    if {[isop $nick $channel]} {
     putlog "-Forbiden words- $nick ($handle) with +o flags said $args on $channel"
   } else {
            putquick "MODE $channel +b $banmask"
            putquick "KICK $channel $nick :$advreason"
            newchanban $channel $banmask $botnick $advreason $adbantime
            putlog "- Nick - $nick - Banmask - $banmask  added to a ban list - Duration - $adbantime minutes"
        }
      }
    }
  }
}


putlog "Forbiden Words Modified By \002:Error:\002 - Loaded "
