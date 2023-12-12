#charset "us-ascii"
//
// memoryEngineActor.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

modify Actor
	knowsAbout(obj) {
		return(canSee(obj) || hasSeen(obj) || getKnown(obj));
	}
	setKnowsAbout(obj) { return(setKnown(obj)); }

	hasSeen(obj) { return(getSeen(obj)); }
	setHasSeen(obj) { return(setSeen(obj)); }

	getKnown(obj) { return(nil); }
	setKnown(obj) { return(nil); }

	getRevealed(obj) { return(nil); }
	setRevealed(obj) { return(nil); }

	getSeen(obj) { return(nil); }
	setSeen(obj) { return(nil); }
;

class MemoryEngine: MemoryEngineObject
	_seenData = perInstance(new LookupTable)
	_knownData = perInstance(new LookupTable)
	_revealedData = perInstance(new LookupTable)

	_getFlag(obj, prop) { return(prop[obj]); }
	_setFlag(obj, prop) { return(prop[obj] = true); }

	getKnown(obj) { return(_getFlag(obj, _knownData)); }
	setKnown(obj) { return(_setFlag(obj, _knownData)); }

	getRevealed(obj) { return(_getFlag(obj, _revealedData)); }
	setRevealed(obj) { return(_setFlag(obj, _revealedData)); }

	getSeen(obj) { return(_getFlag(obj, _seenData)); }
	setSeen(obj) { return(_setFlag(obj, _seenData)); }
;

class MemoryEngineActor: Actor, MemoryEngineObject
	_memoryEngine = perInstance(new MemoryEngine)

	getKnown(obj) { return(_memoryEngine.getKnown(obj)); }
	setKnown(obj) { return(_memoryEngine.setKnown(obj)); }

	getRevealed(obj) { return(_memoryEngine.getRevealed(obj)); }
	setRevealed(obj) { return(_memoryEngine.setRevealed(obj)); }

	getSeen(obj) { return(_memoryEngine.getSeen(obj)); }
	setSeen(obj) { return(_memoryEngine.setSeen(obj)); }
;
