#charset "us-ascii"
//
// memoryEngineMemory.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

#ifndef MEMORY_ENGINE_SIMPLE

// Extensions to the basic memory class.
modify Memory
	room = nil		// room the remembered object was in

	createTime = nil	// turn memory was created on
	writeTime = nil		// turn memory was last updated
	writeCount = 0		// number of times memory was modified
	readTime = nil		// turn memory was last "remembered"
	readCount = 0		// number of times the memory has been read

	// Number of turns since the memory was updated.
	age() { return(libGlobal.totalTurns
		- (self.createTime ? self.createTime : 0)); }

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

	updateProp(prop, val) {
		inherited(prop, val);
		updateWriteTime();
		updateWriteCount();
	}

	// Update the turn number of the memory.
	updateWriteTime() { writeTime = libGlobal.totalTurns; }
	updateWriteCount() { writeCount += 1; }
	updateReadTime() { readTime = libGlobal.totalTurns; }
	updateReadCount() { readCount += 1; }

	// Update a memory using another Memory as the argument.
	updateMemory(data?) {
		updateWriteTime();
		updateWriteCount();
		return(inherited(data));
	}

	// Update
	updateLocation(loc?) {
		room = loc;
		return(true);
	}

	copyFrom(obj) {
		if(inherited(obj) == nil)
			return(nil);

		if(obj.room != nil) room = obj.room;

		if(obj.createTime != nil) createTime = obj.createTime;
		if(obj.writeTime != nil) createTime = obj.writeTime;

		return(true);
	}

	construct() {
		createTime = (libGlobal.totalTurns ? libGlobal.totalTurns : 0);
	}

	lastSeenLocation() { return(room); }
	lastSeenTurn() { return(writeTime); }
;

#endif // MEMORY_ENGINE_SIMPLE
