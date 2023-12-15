#charset "us-ascii"
//
// memoryEngineMemory.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

modify MemoryEngine
	_setFlag(obj, prop, data?) {
		if(active != true) return(nil);
		if(self.(prop) == nil) self.(prop) = new LookupTable();
		if(self.(prop)[obj] == nil) {
			if((data != nil) && data.ofKind(Memory)) {
				self.(prop)[obj] = data.clone();
				return(true);
			}
			self.(prop)[obj] = new Memory();
		}
		self.(prop)[obj].update(data);

		return(true);
	}
;

// Memory types
enum memoryKnown, memoryRevealed, memorySeen;

class Memory: object
	room = nil		// room the remembered object was in
	turn = nil		// turn the remembered object was last seen

	// Properties only used for static memory declarations.
	obj = nil		// object the memory is of
	type = nil		// type of memory

	age() { return(libGlobal.totalTurns - (self.turn ? self.turn : 0)); }

	ageInTurns() {
		local i;

		i = age();

		return('<<toString(i)>> turn<<if(i != 1)>>s<<end>>');
	}

	locationName() {
		if(room == nil) return('nowhere');
		return(room.getOutermostRoom().roomName);
	}

	update(data?) {
		if(data == nil) return(nil);
		if(data.ofKind(Memory))
			return(updateMemory(data));
		else
			return(updateLocation(data));
	}

	updateTimestamp() { turn = libGlobal.totalTurns; }

	updateMemory(data?) { copyFrom(data); }

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

	construct(loc?, tn?) {
		room = loc;
		turn = tn;
	}

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
