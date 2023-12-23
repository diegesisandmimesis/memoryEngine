#charset "us-ascii"
//
// memoryEngineThing.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

modify Thing
	noteSeenBy(actor, prop) {
		actor.setSeen(self);
	}
	basicExamine() {
		local r;

		r = described;
		inherited();
		if((gActor != nil) && (described != r) && described)
			gActor.setDescribed(self);
	}
;
