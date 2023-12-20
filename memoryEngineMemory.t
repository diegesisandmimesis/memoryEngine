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

	createTime = nil	// turn memory was created on
	writeTime = nil		// turn memory was last updated
	writeCount = 0		// number of times memory was modified
	readTime = nil		// turn memory was last "remembered"
	readCount = 0		// number of times the memory has been read

	// Flags for replicating basic adv3 behavior.
	known = nil
	revealed = nil
	seen = nil

	// Properties only used for static memory declarations.
	obj = nil		// object the memory is of
	type = nil		// type of memory

	// Number of turns since the memory was updated.
	age() {
		return(libGlobal.totalTurns
			- (self.createTime ? self.createTime : 0));
	}

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
		self.(prop) = (val ? val : nil);
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
		return(copyFrom(data));
	}

	// Update
	updateLocation(loc?) {
		room = loc;
		return(true);
	}

	copyFrom(obj) {
		if((obj == nil) || !obj.ofKind(Memory))
			return(nil);
		if(obj.room != nil) room = obj.room;

		if(obj.createTime != nil) createTime = obj.createTime;
		if(obj.writeTime != nil) createTime = obj.writeTime;

		if(obj.known != nil) known = obj.known;
		if(obj.revealed != nil) revealed = obj.revealed;
		if(obj.seen != nil) seen = obj.seen;

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

	construct() {
		createTime = (libGlobal.totalTurns ? libGlobal.totalTurns : 0);
	}
;
