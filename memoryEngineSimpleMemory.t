#charset "us-ascii"
//
// memoryEngineSimpleMemory.t
//
//	An alternative to full memory tracking.  Here we more or less
//	replicate the "stock" adv3 seen/known/revealed behavior by
//	just keeping track of a boolean state.
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

class SimpleMemory: MemoryEngineObject
	// Flags for replicating basic adv3 behavior.
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

#ifdef MEMORY_ENGINE_SIMPLE
class Memory: SimpleMemory;
#endif // MEMORY_ENGINE_SIMPLE
