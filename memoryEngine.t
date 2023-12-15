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
	active = true

	// These will contain LookupTables, created on first write.
	// We keep the data type separate (instead of basically making a
	// single big database with a row indicating the record type) to
	// make single-type lookups and updates faster.  The asumption being
	// that all the native lookups and updates (e.g. updating the "seen"
	// data every turn) will dominate the usage.
	_seenData = nil
	_knownData = nil
	_revealedData = nil

	// Abstract getter and setter for all records.
	_getFlag(obj, prop) {
		return(active ? (self.(prop) ? self.(prop)[obj] : nil) : nil);
	}

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

	// Type-specific getters and setters.
	getKnown(obj) { return(_getFlag(obj, &_knownData)); }
	setKnown(obj, data?) { return(_setFlag(obj, &_knownData, data)); }

	getRevealed(obj) { return(_getFlag(obj, &_revealedData)); }
	setRevealed(obj, data?) { return(_setFlag(obj, &_revealedData, data)); }

	getSeen(obj) { return(_getFlag(obj, &_seenData)); }
	setSeen(obj, data?) { return(_setFlag(obj, &_seenData, data)); }

	// Check and toggle for the active flag.
	// This is provided to turn off memory stuff for NPCs that don't
	// need it.
	isActive() { return(active == true); }
	setActive(v?) { active = ((v == true) ? true : nil); }

	addMemory(obj) {
		if((obj == nil) || !obj.ofKind(Memory))
			return(nil);
		switch(obj.type) {
			case memoryKnown:
				setKnown(obj.obj, obj);
				break;
			case memoryRevealed:
				setRevealed(obj.obj, obj);
				break;
			case memorySeen:
				setSeen(obj.obj, obj);
				break;
			default:
				_error('unknown memory type');
				return(nil);
		}

		return(true);
	}

	initializeMemoryEngine(obj) {
	}
;
