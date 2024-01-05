#charset "us-ascii"
//
// memoryEngineMemory.t
//
//	Provides the memory class.
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

// Base memory class.
// If the module is compiled with -D MEMORY_ENGINE_SIMPLE this is all that
// is used.  But by default (compiled without any flags) the Memory
// class will be extended in the code block following this declaration.
// In addition, this declaration only includes the "seen" flag, and no
// flags for other senses.  This mirrors the stock adv3 behavior, but by
// default the additions in memoryEngineSenses.t will extend this to the
// other senses as well.
class Memory: MemoryEngineObject
	// Flags for replicating basic adv3 behavior.
	described = nil		// has the object been directly examined
	known = nil		// has the object been detected by the senses
	revealed = nil		// has the object been revealed
	seen = nil		// has the object been seen

	// Properties only used for static memory declarations.
	_obj = nil		// object the memory is of

	// Flag for whether this memory is directly accessible.
	// This is true for most "normal" memories and nil for
	// "synthetic" memories (things the actor doesn't actually
	// know, but are used for tracking game state stuff).
	_isListed = true

	// Stub methods for stuff that isn't tracked in the base
	// memory model.  This is just to make fallback more graceful if
	// the module is compiled with -D MEMORY_ENGINE_SIMPLE for testing.
	age() { return(0); }
	ageInTurns() { return('0 turns'); }
	locationName() { return('nowhere'); }

	// Generic memory update method.  Arg is another Memory instance.
	update(data?) {
		if(data == nil) return(nil);
		if(data.ofKind(Memory))
			return(updateMemory(data));
		return(nil);
	}

	// Convenience method for updating a memory property.  Mostly
	// provided to make implementing named getters and setters less
	// verbose.
	updateProp(prop, val) { self.(prop) = (val ? val : nil); }

	// Update a memory using another Memory as the argument.
	updateMemory(data?) { return(copyFrom(data)); }

	// Stub method for updating the location.  Not tracked in the base
	// class.
	updateLocation(loc?) { return(nil); }

	clearMemory() {
		described = nil;
		known = nil;
		revealed = nil;
		seen = nil;

		obj = nil;
	}

	// Copy properties from the argument, which has to be another
	// Memory instance.
	copyFrom(obj, clear?) {
		if((obj == nil) || !obj.ofKind(Memory))
			return(nil);

		if(clear == true)
			clearMemory();

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

	// If the argument is a memory engine, add ourselves to it.
	_tryMemoryEngine(obj) {
		if((obj == nil) || !obj.ofKind(MemoryEngine))
			return(nil);
		return(obj.addMemory(self));
	}

	// If the argument is an actor, try to add ourselves to their
	// memory engine, initializing it if necessary.
	_tryMemoryActor(obj) {
		if((obj == nil) || !obj.ofKind(Actor))
			return(nil);

		// At this stage of preinit, actors that don't have
		// statically declared memory engines won't have had a
		// default created for them yet, so we have to manually
		// call the initializer to make sure there's an engine
		// for us to add ourselves to.  If the actor DOES already
		// have a memory engine, calling the initializer does
		// nothing.
		obj.initializeMemoryEngineActor();

		return(_tryMemoryEngine(obj.memoryEngine));
	}

	// More stub methods for stuff we don't track in the base class.
	lastSeenLocation() { return(nil); }
	lastSeenTurn() { return(0); }

	// True for "normal" memories.
	isListed() { return(_isListed == true); }
;

#ifndef MEMORY_ENGINE_SIMPLE

// Extensions to the basic memory class.
// This is all in a big preprocessor conditional, so all of this
// gets applied if -D MEMORY_ENGINE_SIMPLE is NOT given at compile-time,
// which is the default.
modify Memory
	room = nil		// room the remembered object was in

	createTime = nil	// turn memory was created on
	writeTime = nil		// turn memory was last updated
	writeCount = 0		// number of times memory was modified
	readTime = nil		// turn memory was last "remembered"
	readCount = 0		// number of times the memory has been read

	clearMemory() {
		inherited();

		room = nil;
		createTime = nil;
		writeTime = nil;
		writeCount = 0;
		readTime = nil;
		readCount = 0;
	}

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

	// Utility method to update a single property.
	// We also update the write time and count.
	updateProp(prop, val) {
		inherited(prop, val);
		updateWriteCount();
	}

	// Update the turn number and count of the memory.
	updateWriteTime() { writeTime = libGlobal.totalTurns; }
	updateWriteCount() {
		if(writeTime == libGlobal.totalTurns) return;
		writeCount += 1;
		updateWriteTime();
	}
	updateReadTime() { readTime = libGlobal.totalTurns; }
	updateReadCount() {
		if(readTime == libGlobal.totalTurns) return;
		readCount += 1;
		updateReadTime();
	}

	// Update a memory using another Memory as the argument.
	updateMemory(data?) {
		return(inherited(data));
	}

	// Update the location of the memory.
	updateLocation(loc?) {
		updateWriteCount();
		room = loc;
		return(true);
	}

	// Set our properties from the given object's.
	// We do all the stuff the base class definition does, and then
	// handle some additional properties.
	// We don't track counts, maybe a misfeature?
	copyFrom(obj) {
		if(inherited(obj) == nil)
			return(nil);

		if(obj.room != nil) room = obj.room;
		if(obj.createTime != nil) createTime = obj.createTime;
		if(obj.writeTime != nil) createTime = obj.writeTime;

		if(createTime == nil)
			createTime = libGlobal.totalTurns;

		return(true);
	}

	// The constructor sets the memory's creation time.
	construct() {
		createTime = (libGlobal.totalTurns ? libGlobal.totalTurns : 0);
	}

	lastSeenLocation() { return(room); }
	lastSeenTurn() { return(writeTime); }
;

#endif // MEMORY_ENGINE_SIMPLE
