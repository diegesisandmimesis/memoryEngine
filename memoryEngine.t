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
//		canSense(obj)
//			boolean true if the actor can detect the given object
//			via any sense
//
//		hasSensed(obj)
//			boolean true if the actor has previously detected the
//			given object via any sense
//
//		getMemory(obj)
//			returns the actor's Memory instance for the given object
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
//	If the module is NOT compiled with -D MEMORY_ENGINE_NO_SENSES then
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
// NPC MEMORIES
//
//	By default NPCs don't look around/sense their environments.  If
//	you want an NPC to automagically sense their surroundings via the
//	same mechanism the player does (Actor.lookAround()) just add
//	Alert to the NPC's superclass list:
//
//		+alice: Person, Alert 'alice' 'Alice'
//			"She looks like the first person you'd turn to
//			in a problem. "
//
//			isHer = true
//			isProperName = true
//		;
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
//		+Memory ->pebble known = true;
//
//	In this example the NPC alice will start the game knowing about
//	the pebble object.
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
// DEBUGGING COMMANDS
//
//	When compiled with -D __DEBUG_MEMORY_ENGINE, the module provides
//	the following debugging commands:
//
//		>MA [actor]
//			Shows a summary of each of the actor's memories
//
//		>MA [actor] actor
//			Shows a summary of each of the actor's memories
//			about other actors
//
//		>MA [actor] object
//			Shows a summary of each of the actor's memories
//			about objects
//
//		>MA [actor] room
//			Shows a summary of each of the actor's memories
//			about rooms
//
//		>MA [actor] [object]
//			Shows a summary of the actor's memories of the
//			given object
//
//		>MO [object]
//			Shows a summary of the player's memories of the
//			given object
//
//		>ME
//			Displays information about the total number of
//			memory engines and memories currently in the game
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

	// LookupTable for memories.  Keys are IDs or objects, values are
	// Memory instances.
	_memory = nil

	// Create the memory table.
	_initMemoryTable() { self._memory = new LookupTable(); }

	// Return the requested memory.
	_getMemory(id) {
		return(active ? (self._memory ? self._memory[id] : nil) : nil);
	}

	// Create a new, "empty" memory for the given ID.
	_createMemory(id) {
		if(active != true) return(nil);
		if(self._memory == nil) _initMemoryTable();
		self._memory[id] = new Memory();
		return(self._memory[id]);
	}

	// Set the memory for the given ID.  If the second arg is a
	// Memory instance, it will be used directly.  If it is nil,
	// the memory will be set to nil.  Otherwise, any properties
	// directly defined on the object will be copied onto the memory.
	// This method (with the leading underscore) is the "raw"
	// memory set method.  It doesn't do checks to see if the memory
	// is allowed to be set (i.e. it doesn't check if the memory engine
	// is active).
	_setMemory(id, data) {
		local m;

		// Make sure we have an ID.
		if(id == nil)
			return(nil);

		// If the second arg is nil, clear the memory.
		if(data == nil) {
			_memory[id] = nil;
			return(true);
		}

		// If the second arg is a memory, use it.
		if(data.ofKind(Memory)) {
			_memory[id] = data;
			return(true);
		}

		// Create a new, empty memory.
		m = _createMemory(id);

		// Go through all the properties directly defined on the
		// second arg and add them to the new memory.
		data.getPropList().forEach(function(o) {
			if(!data.propDefined(o, PropDefDirectly))
				return;
			m.(o) = data.(o);
		});

		return(true);
	}

	// Set a memory.
	// Unlike _setMemory() (above), this method applies checks.
	// It also will update an existing memory instead of replacing it.
	setMemory(id, data) {
		// If we're not active, we don't do anything.
		if(active != true)
			return(nil);

		// Init the memory table if necessary.
		if(self._memory == nil)
			_initMemoryTable();

		// If the memory doesn't exist, create it.
		if(self._memory[id] == nil) {
			// If our second arg is non-nil we use it to
			// create a new memory and return.
			if(data != nil)
				return(_setMemory(id, data));

			// Create an empty memory and return (because
			// we know our data is nil).
			_createMemory(id);
			return(true);
		}

		// If we're here, then we know our memory is non-nil.  If
		// our data IS nil, then we have nothing to do.
		if(data == nil)
			return(true);

		// Update the existing memory.
		return(self._memory[id].update(data));
	}

	// Utility method to return the value of a property on a memory.
	_getProp(id, prop) {
		local m;

		if((m = _getMemory(id)) == nil) return(nil);
		return(m.(prop));
	}

	// Utility method to set the value of a property on a memory.
	_setProp(id, prop, val?) {
		local m;

		if(active != true)
			return(nil);

		if((m = _getMemory(id)) == nil) {
			setMemory(id, nil);
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
		if(obj._obj == nil)
			return(nil);

		return(setMemory(obj._obj, obj));
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

	// Returns boolean true if the given memory is a "listed" entity.
	// This is mostly to exclude the memory of room parts and other
	// "incidental" things like that.
	isListed(id) {
		local m;

		// Make sure we have an ID.
		if(id == nil)
			return(nil);

		// If we don't have a memory, we're not listed.
		if((m = _memory[id]) == nil)
			return(nil);

		// Check the memory, which can always preempt our
		// decision.
		if(m.isListed() != true)
			return(nil);

		// Room parts are always ignored by default.
		if(id.ofKind(RoomPart))
			return(nil);

		// We're listed.
		return(true);
	}
;
