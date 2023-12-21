#charset "us-ascii"
//
// memoryEngineActor.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

modify Thing
	noteSeenBy(actor, prop) {
		inherited(actor, prop);
		actor.setSeen(self);
	}
;
