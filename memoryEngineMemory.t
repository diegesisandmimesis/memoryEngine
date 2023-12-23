#charset "us-ascii"
//
// memoryEngineMemory.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

class Memory: MemoryEngineObject
	// Flags for replicating basic adv3 behavior.
	described = nil
	known = nil
	revealed = nil
	seen = nil

	knowledge = nil

	// Properties only used for static memory declarations.
	obj = nil		// object the memory is of

	age() { return(0); }
	ageInTurns() { return('0 turns'); }
	locationName() { return('nowhere'); }

	update(data?) {
		if(data == nil) return(nil);
		if(data.ofKind(Memory))
			return(updateMemory(data));
		return(nil);
	}

	updateProp(prop, val) { self.(prop) = (val ? val : nil); }

	// Update a memory using another Memory as the argument.
	updateMemory(data?) { return(copyFrom(data)); }

	updateLocation(loc?) { return(nil); }

	copyFrom(obj) {
		if((obj == nil) || !obj.ofKind(Memory))
			return(nil);

		if(obj.described != nil) described = obj.described;
		if(obj.known != nil) known = obj.known;
		if(obj.revealed != nil) revealed = obj.revealed;
		if(obj.seen != nil) seen = obj.seen;

		return(true);
	}

	// Returns a copy of this memory
	clone() {
		local m;

		m = new Memory();
		m.copyFrom(self);

		return(m);
	}

	initializeMemory() {
		// We only initialize memories that are declared in the
		// source, and we only care about those if they're declared
		// on an actor (or their memory engine).
		if(location == nil)
			return;

		if(_tryMemoryEngine(location) == true)
			return;
		if(_tryMemoryActor(location) == true)
			return;
		_error('orphaned memory');
	}

	_tryMemoryEngine(obj) {
		if((obj == nil) || !obj.ofKind(MemoryEngine))
			return(nil);
		return(obj.addMemory(self));
	}

	_tryMemoryActor(obj) {
		if((obj == nil) || !obj.ofKind(Actor))
			return(nil);
		obj.initializeMemoryEngineActor();
		return(_tryMemoryEngine(obj.memoryEngine));
	}

	lastSeenLocation() { return(nil); }
	lastSeenTurn() { return(0); }
;

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
