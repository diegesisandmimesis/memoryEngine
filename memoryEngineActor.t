#charset "us-ascii"
//
// memoryEngineActor.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

modify Actor
	//memoryEngine = perInstance(new MemoryEngine)
	memoryEngine = nil

	useMemoryEngine = true

	knowsAbout(obj) {
		return(canSee(obj) || hasSeen(obj) || getKnown(obj));
	}
	setKnowsAbout(obj) { return(setKnown(obj)); }

	hasSeen(obj) { return(getSeen(obj)); }
	setHasSeen(obj, loc?) { return(setSeen(obj, loc)); }

	getKnown(obj) { return(memoryEngine.getKnown(obj)); }
	setKnown(obj, loc?) { return(memoryEngine.setKnown(obj, loc)); }

	getRevealed(obj) { return(memoryEngine.getRevealed(obj)); }
	setRevealed(obj, loc?) { return(memoryEngine.setRevealed(obj, loc)); }

	getSeen(obj) { return(memoryEngine.getSeen(obj)); }
	setSeen(obj, loc?) {
		return(memoryEngine.setSeen(obj,
			(loc ? loc : self.getOutermostRoom())));
	}

	noteSeenBy(actor, prop) {
		inherited(actor, prop);
		actor.setSeen(self);
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

