#charset "us-ascii"
//
// memoryEnginePreinit.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

memoryEnginePreinit: MemoryEngineObject, PreinitObject
	execute() {
		initMemories();
		initMemoryEngines();
	}

	initMemories() {
		forEachInstance(Memory, function(o) {
			o.initializeMemory();
		});
	}

	initMemoryEngines() {
		forEachInstance(MemoryEngine, function(o) {
			o.initializeMemoryEngine();
		});
	}
;
