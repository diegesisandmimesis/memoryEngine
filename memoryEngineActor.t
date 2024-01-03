#charset "us-ascii"
//
// memoryEngineActor.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

// Modifications for the Actor class.
// By default all actors get their own memory engine.
modify Actor
	// By default, Actors use memory engines.
	useMemoryEngine = true

	// Property to hold the MemoryEngine instance.
	memoryEngine = nil

	// Replacements for the stock adv3 "knows" methods.
	knowsAbout(obj) {
		return(canSense(obj) || hasSensed(obj) || getKnown(obj));
	}
	setKnowsAbout(obj) { return(setKnown(obj)); }

	// Replacements for the stock adv3 "seen" methods.
	hasSeen(obj) { return(getSeen(obj)); }
	setHasSeen(obj) { return(setSeen(obj)); }

	// Generic sense/sense memory methods.
	// These are used for "automatic" sense perceptions.  That is,
	// sensing something as part of the ambient environment, rather
	// than as a direct, intentional examination of the thing being
	// sensed:  the player walks into a room containing a refrigerator
	// and they'll see it even if they weren't looking for a fridge.
	canSense(obj) { return(canSee(obj) || canHear(obj) || canSmell(obj)); }
	hasSensed(obj) {
		return(getSeen(obj) || getHeard(obj) || getSmelled(obj));
	}

	// General utility method for getting a property off a method,
	// checking for the existence of a memory engine first.
	_getMemoryProp(prop, obj) {
		return(memoryEngine ? memoryEngine.(prop)(obj) : nil);
	}

	getDescribed(obj) { return(_getMemoryProp(&getDescribed, obj)); }
	setDescribed(obj) { return(_getMemoryProp(&setDescribed, obj)); }

	getKnown(obj) { return(_getMemoryProp(&getKnown, obj)); }
	setKnown(obj) { return(_getMemoryProp(&setKnown, obj)); }

	getRevealed(obj) { return(_getMemoryProp(&getKnown, obj)); }
	setRevealed(obj) { return(_getMemoryProp(&setKnown, obj)); }

	getSeen(obj) { return(_getMemoryProp(&getSeen, obj)); }
	setSeen(obj) {
		if(memoryEngine == nil)
			return(nil);
		if(memoryEngine.setSeen(obj) != true)
			return(nil);
		memoryEngine.setLocation(obj, obj.getOutermostRoom());
		return(true);
	}

	getMemory(id) {
		return(memoryEngine ? memoryEngine.getMemory(id) : nil);
	}

	// Set this actor's memory engine.
	// Called either by initializeMemoryEngineActor() (below), or
	// from MemoryEngine.initializeMemoryEngine() (if the engine
	// is explicitly declared in the source).
	setMemoryEngine(obj) {
		if((obj == nil) || !obj.ofKind(MemoryEngine))
			return(nil);

		memoryEngine = obj;
		obj.actor = self;

		return(true);
	}

	// Called at preinit, we add create a new memory engine for this
	// actor if it doesn't already have one (because one was explicitly
	// declared in the source), unless it's been disabled for this actor.
	initializeMemoryEngineActor() {
		if((memoryEngine != nil) || (useMemoryEngine != true))
			return;

		setMemoryEngine(new MemoryEngine());
	}
;
