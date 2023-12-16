#charset "us-ascii"
//
// memoryEngineMemory.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

// Memory types
enum memoryKnown, memoryRevealed, memorySeen;

// Abstract memory class.
class Memory: object
	room = nil		// room the remembered object was in
	turn = nil		// turn the remembered object was last seen

	// Properties only used for static memory declarations.
	obj = nil		// object the memory is of
	type = nil		// type of memory

	// Number of turns since the memory was updated.
	age() { return(libGlobal.totalTurns - (self.turn ? self.turn : 0)); }

	// Returns a text string of the age in turns.
	ageInTurns() {
		local i;

		i = age();

		return('<<toString(i)>> turn<<if(i != 1)>>s<<end>>');
	}

	// Returns the name of the location associated with the memory.
	locationName() {
		if(room == nil) return('nowhere');
		return(room.getOutermostRoom().roomName);
	}

	// Update this memory.
	// Argument is either a Memory instance or the location of
	// the memory "update".
	update(data?) {
		if(data == nil) return(nil);
		if(data.ofKind(Memory))
			return(updateMemory(data));
		else
			return(updateLocation(data));
	}

	// Update the turn number of the memory.
	updateTimestamp() { turn = libGlobal.totalTurns; }

	// Update a memory using another Memory as the argument.
	updateMemory(data?) {
		updateTimestamp();
		return(copyFrom(data));
	}

	// Update
	updateLocation(loc?) {
		room = loc;
		updateTimestamp();
		return(true);
	}

	copyFrom(obj) {
		if((obj == nil) || !obj.ofKind(Memory))
			return(nil);
		if(obj.room != nil) room = obj.room;
		if(obj.turn != nil) turn = obj.turn;
		return(true);
	}

	// Returns a copy of this memory
	clone() { return(new Memory().copyFrom(self)); }

	initializeMemory() {
		if(_tryMemoryEngine(location) == true)
			return;
		_error('orphaned memory');
	}

	_tryMemoryEngine(obj) {
		if((obj == nil) || !obj.ofKind(MemoryEngine))
			return(nil);
		return(obj.addMemory(self));
	}
;
