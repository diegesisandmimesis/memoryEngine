#charset "us-ascii"
//
// memoryEnginePreinit.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

memoryEnginePreinit: MemoryEngineObject, PreinitObject
	syslogID = 'memoryEnginePreinit'

	execute() {
		initMemories();
		initMemoryEngines();
		initMemoryEngineActors();
	}

	initMemories() {
		_debug('initMemories()');
		forEachInstance(Memory, function(o) {
			o.initializeMemory();
		});
	}

	initMemoryEngines() {
		_debug('initMemoryEngines()');
		forEachInstance(MemoryEngine, function(o) {
			o.initializeMemoryEngine();
		});
	}

	initMemoryEngineActors() {
		_debug('initMemoryEngineActors()');
		forEachInstance(Actor, function(o) {
			o.initializeMemoryEngineActor();
		});
	}
;
