#charset "us-ascii"
//
// sample.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the memoryEngine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f makefile.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

versionInfo: GameID
        name = 'memoryEngine Library Demo Game'
        byline = 'Diegesis & Mimesis'
        desc = 'Demo game for the memoryEngine library. '
        version = '1.0'
        IFID = '12345'
	showAbout() {
		"This is a simple test game that demonstrates the features
		of the memoryEngine library.
		<.p>
		Consult the README.txt document distributed with the library
		source for a quick summary of how to use the library in your
		own games.
		<.p>
		The library source is also extensively commented in a way
		intended to make it as readable as possible. ";
	}
;

startRoom: Room 'Void'
	"This is a featureless void with a sign on the wall.  There's another
	room to the north. "
	north = middleRoom
;
+sign: Fixture 'sign' 'sign'
	"<q>Reading this reveals the terrible secret of the sign.</q>
	<.reveal signSecret> ";
;
+pebble: Thing 'small round pebble' 'pebble'
	"A small, round pebble. (Turn <<toString(gTurn)>>) <.reveal foozle>"
	dobjFor(Examine) {
		action() {
			inherited();
			//"\nFoo = <<toString(gTurn)>>\n ";
			//gReveal('foozle');
		}
	}
;
+flower: Thing 'smelly flower' 'flower'
	"A smelly flower. "
	smellPresence = true
;
+me: Actor;

middleRoom: Room 'Middle Room'
	"This is the middle room.  There are rooms to the north and south. "
	north = northRoom
	south = startRoom
;
+alice: Person, Alert 'alice' 'Alice'
	"She looks like the first person you'd turn to in a problem. "
	isHer = true
	isProperName = true
;
++Memory ->pebble
	seen = true
	room = startRoom
;

northRoom: Room 'North Room'
	"This is the north room.  There's another room to the south. "
	south = middleRoom
;
+bob: Person 'bob' 'Bob'
	"He looks like Robert, only shorter. "
	isHim = true
	isProperName = true
	useMemoryEngine = nil
;
+rock: Thing 'ordinary rock' 'rock' "An ordinary rock. ";

gameMain: GameMainDef initialPlayerChar = me;
