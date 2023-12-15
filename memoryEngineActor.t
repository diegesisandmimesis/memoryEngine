#charset "us-ascii"
//
// memoryEngineActor.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

modify Actor
	memoryEngine = perInstance(new MemoryEngine)

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
;

