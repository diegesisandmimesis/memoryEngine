#charset "us-ascii"
//
// memoryEngineManager.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

memoryEngineManager: MemoryEngineObject
	_resolveActor(actor?) {
		if((actor != nil) && actor.ofKind(Actor))
			return(actor);
		if(gActor != nil)
			return(gActor);
		return(nil);
	}

	_callMethod(actor, id, prop) {
		if((actor == _resolveActor(actor)) == nil) return(nil);
		return(actor.(prop)(id));
	}

	getKnown(actor, id) { return(_callMethod(actor, id, &getKnown)); }
	setKnown(actor, id) { return(_callMethod(actor, id, &setKnown)); }

	getHeard(actor, id) { return(_callMethod(actor, id, &getHeard)); }
	setHeard(actor, id) { return(_callMethod(actor, id, &setHeard)); }

	getSmelled(actor, id) { return(_callMethod(actor, id, &getSmelled)); }
	setSmelled(actor, id) { return(_callMethod(actor, id, &setSmelled)); }

	getTasted(actor, id) { return(_callMethod(actor, id, &getTasted)); }
	setTasted(actor, id) { return(_callMethod(actor, id, &setTasted)); }

	getTouched(actor, id) { return(_callMethod(actor, id, &getTouched)); }
	setTouched(actor, id) { return(_callMethod(actor, id, &setTouched)); }

	getRevealed(actor, id) { return(_callMethod(actor, id, &getRevealed)); }
	setRevealed(actor, id) { return(_callMethod(actor, id, &setRevealed)); }

	getSeen(actor, id) { return(_callMethod(actor, id, &getSeen)); }
	setSeen(actor, id) { return(_callMethod(actor, id, &setSeen)); }
;
