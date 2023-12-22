#charset "us-ascii"
//
// memoryEngine.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

// Module ID for the library
memoryEngineModuleID: ModuleID {
        name = 'Memory Engine Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

class MemoryEngineObject: Syslog syslogID = 'MemoryEngine';

class MemoryEngine: MemoryEngineObject
	// Toggle for engine;  if nil, we don't record new memories and
	// return nil for all memory checks.
	active = true

	// Actor we belong to.
	actor = nil

	// These will contain LookupTables, created on first write.
	// We keep the data type separate (instead of basically making a
	// single big database with a row indicating the record type) to
	// make single-type lookups and updates faster.  The asumption being
	// that all the native lookups and updates (e.g. updating the "seen"
	// data every turn) will dominate the usage.
	//_seenData = nil
	//_knownData = nil
	//_revealedData = nil

	_memory = nil

	_getMemory(id) {
		return(active ? (self._memory ? self._memory[id] : nil) : nil);
	}

	_setMemory(id, data) {
		if(active != true) return(nil);
		if(self._memory == nil) self._memory = new LookupTable();
		if(self._memory[id] == nil) {
			if(data != nil) {
				self._memory[id] = data.clone();
				return(true);
			}
			self._memory[id] = new Memory();
		}
		return(self._memory[id].update(data));
	}

	_getProp(id, prop) {
		local m;

		if((m = _getMemory(id)) == nil) return(nil);
		return(m.(prop));
	}

	_setProp(id, prop, val?) {
		local m;

		if(active != true) return(nil);
		if((m = _getMemory(id)) == nil) {
			_setMemory(id, nil);
			if((m = _getMemory(id)) == nil)
				return(nil);
		}
		m.updateProp(prop, val);

		return(true);
	}

	// Wrapper for _setProp that also sets the known property
	// to be true.  Used for direct sense properties; seeing something
	// automatically makes it known.
	_setSenseProp(id, prop, val?) {
		if(_setProp(id, prop, val) != true)
			return(nil);
		return(setKnown(id));
	}
		
	// Type-specific getters and setters.
	getKnown(obj) { return(_getProp(obj, &known)); }
	setKnown(obj) { return(_setProp(obj, &known, true)); }

	getRevealed(obj) { return(_getProp(obj, &revealed)); }
	setRevealed(obj) { return(_setProp(obj, &revealed, true)); }

	getSeen(obj) { return(_getProp(obj, &seen)); }
	setSeen(obj) { return(_setSenseProp(obj, &seen, true)); }

	getLocation(obj) { return(_getProp(obj, &room)); }
	setLocation(obj, v) { return(_setProp(obj, &room, v)); }

	getTimestamp(obj) { return(_getProp(obj, &writeTime)); }

	// Check and toggle for the active flag.
	// This is provided to turn off memory stuff for NPCs that don't
	// need it.
	isActive() { return(active == true); }
	setActive(v?) { active = ((v == true) ? true : nil); }

	addMemory(obj) {
		if((obj == nil) || !obj.ofKind(Memory))
			return(nil);
		if(obj.obj == nil)
			return(nil);

		return(_setMemory(obj.obj, obj));
	}

	getMemory(id) { return(_getMemory(id)); }

	// Called at preinit for instances explicitly declared in the
	// source.
	// Try to add ourselves to our actor.
	initializeMemoryEngine() {
		if((location == nil) || !location.ofKind(Actor))
			return;
		location.setMemoryEngine(self);
	}
;
