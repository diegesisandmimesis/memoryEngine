#charset "us-ascii"
//
// memoryEngineThing.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

modify Thing
	noteSeenBy(actor, prop) { actor.setSeen(self); }
	basicExamine() {
		local r;

		r = described;
		inherited();
		if((gActor != nil) && (described != r) && described)
			gActor.setDescribed(self);
	}

	basicExamineListen(explicit) {
		if(explicit == true)
			gActor.setHeard(self);
		inherited(explicit);
	}

	basicExamineSmell(explicit) {
		if(explicit == true)
			gActor.setSmelled(self);
		inherited(explicit);
	}

	basicExamineTaste() {
		gActor.setTasted(self);
		inherited();
	}

	basicExamineFeel() {
		gActor.setTouched(self);
		inherited();
	}
;
