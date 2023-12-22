#charset "us-ascii"
//
// memoryEngineManager.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

// Singleton for handling the global macros.
memoryEngineManager: MemoryEngineObject
	// Canonicalize the actor.
	// Returns the arg if the arg is an actor, or gActor if gActor is
	// defined, and nil otherwise.
	_resolveActor(actor?) {
		if((actor != nil) && actor.ofKind(Actor))
			return(actor);
		if(gActor != nil)
			return(gActor);
		return(nil);
	}

	// Generic way of calling a method on an actor.
	_callMethod(actor, id, prop) {
		if((actor == _resolveActor(actor)) == nil) return(nil);
		return(actor.(prop)(id));
	}

	getKnown(actor, id) { return(_callMethod(actor, id, &getKnown)); }
	setKnown(actor, id) { return(_callMethod(actor, id, &setKnown)); }

	getRevealed(actor, id) { return(_callMethod(actor, id, &getRevealed)); }
	setRevealed(actor, id) { return(_callMethod(actor, id, &setRevealed)); }

	getHeard(actor, id) { return(_callMethod(actor, id, &getHeard)); }
	setHeard(actor, id) { return(_callMethod(actor, id, &setHeard)); }

	getSmelled(actor, id) { return(_callMethod(actor, id, &getSmelled)); }
	setSmelled(actor, id) { return(_callMethod(actor, id, &setSmelled)); }

	getTasted(actor, id) { return(_callMethod(actor, id, &getTasted)); }
	setTasted(actor, id) { return(_callMethod(actor, id, &setTasted)); }

	getTouched(actor, id) { return(_callMethod(actor, id, &getTouched)); }
	setTouched(actor, id) { return(_callMethod(actor, id, &setTouched)); }

	getSeen(actor, id) { return(_callMethod(actor, id, &getSeen)); }
	setSeen(actor, id) { return(_callMethod(actor, id, &setSeen)); }
;
