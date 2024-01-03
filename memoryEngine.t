#charset "us-ascii"
//
// memoryEngine.t
//
//	A TADS3/adv3 module for working with sense memories and knowledge.
//
//	By default adv3 keeps track of what an actor knows about by setting
//	flags on objects.  This module tracks this kind of information in
//	lookup tables, by default on a per-actor basis.
//
//
// BASIC USAGE
//
//	In addition to accessing memories via the standard adv3 methods
//	(knowsAbout(), hasSeen(), and so on), the module adds several
//	methods to Actor:
//
//
//		canSense(obj)
//			boolean true if the actor can detect the given object
//			via any sense
//
//		hasSensed(obj)
//			boolean true if the actor has previously detected the
//			given object via any sense
//
//		getMemory(obj)
//			returns the actor's Memory instace for the given object
//
//
//	In addition, there getters and setters for each Memory property:
//
//		getDescribed(obj)
//		setDescribed(obj)
//			Get or set the "described" property, indicating that
//			the actor has directly examined the object
//
//		getKnown(obj)
//		setKnown(obj)
//			Get or set the "known" property, indicating that
//			the actor knows about the object
//
//		getRevealed(obj)
//		setRevealed(obj)
//			Get or set the "revealed" property, indicating that
//			the actor knows about the subject.  In base adv3
//			this is for conversational subject instead of physical
//			objects, but this module is agnostic about the class
//			of object a memory represents
//
//		getSeen(obj)
//		setSeen(obj)
//			Get or set the "seen" property, indicating that
//			the actor has seen the object
//
//
//	If the module is NOT compiled with -D SIMPLE_MEMORY_NO_SENSES then
//	the following methods will also be available:
//
//		getHeard(obj)
//		setHeard(obj)
//			Get or set the "heard" property, indicating that
//			the actor has heard the object
//
//		getSmelled(obj)
//		setSmelled(obj)
//			Get or set the "smelled" property, indicating that
//			the actor has smelled the object
//
//		getTasted(obj)
//		setTasted(obj)
//			Get or set the "tasted" property, indicating that
//			the actor has tasted the object
//
//		getTouched(obj)
//		setTouched(obj)
//			Get or set the "touched" property, indicating that
//			the actor has touched the object
//
//
// DECLARING MEMORIES IN SOURCE
//
//	You can manually add memories to an actor (so they're available
//	at the start of the game) via something like:
//
//		alice: Person 'alice' 'Alice'
//			"She looks like the first person you'd turn to
//			in a problem. "
//			isHer = true
//			isProperName = true
//		;
//		+Memory ->pebble ->true;
//
//	In this example the NPC alice will start the game knowing about
//	the pebble object.
//
//	The template is:
//
//		Memory ->obj ->known? ->revealed? ->seen? ->described?
//
//	Where obj is the object the memory is of, and the remaining arguments
//	are the named memory flags.
//
//
//
// COMPILER FLAGS
//
//	-D MEMORY_ENGINE_SIMPLE
//		Compiling with this flag will disable most of the extra
//		features, and the module will just replicate the functionality
//		of base adv3 (only using lookup tables instead of object
//		properties)
//
//	-D MEMORY_ENGINE_NO_SENSES
//		Compiling with this flag will disable the additional sense
//		data tracking.  This means that sight will be the only sense
//		tracked (replicating the stock adv3 behavior).  By default
//		the module will keep track of all five senses.
//
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

// Generic module-specific object class.
// We do this to make logging easier.
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
		if(_setProp(id, prop, val) != true) {
			return(nil);
		}
		return(setKnown(id));
	}
		
	// Type-specific getters and setters.
	getDescribed(obj) { return(_getProp(obj, &described)); }
	setDescribed(obj) { return(_setProp(obj, &described, true)); }

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

	isListed(id) {
		local m;

		if(id == nil) return(nil);
		if((m = _memory[id]) == nil) return(nil);
		if(m.isListed() != true) return(nil);
		if(id.ofKind(RoomPart)) return(nil);
		return(true);
	}
;
