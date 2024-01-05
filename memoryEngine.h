//
// memoryEngine.h
//

// Uncomment to enable debugging options.
//#define __DEBUG_MEMORY_ENGINE

// Compile-time flag that disables most of the "advanced" memory
// features.  With this, the module just replicates the stock adv3
// known/revealed/seen behavior.
//#define MEMORY_ENGINE_SIMPLE

#include "syslog.h"
#ifndef SYSLOG_H
#error "This module requires the syslog module."
#error "https://github.com/diegesisandmimesis/syslog"
#error "It should be in the same parent directory as this module.  So if"
#error "memoryEngine is in /home/user/tads/memoryEngine, then"
#error "syslog should be in /home/user/tads/syslog ."
#endif // SYSLOG_H

#undef gRevealed
#define gRevealed(id) (memoryEngineManager.getRevealed(gActor, id))

#undef gReveal
#define gReveal(id) (memoryEngineManager.setRevealed(gActor, id))

#define gKnowsAbout(id) (memoryEngineManager.getKnown(gActor, id))
#define gLearnAbout(id) (memoryEngineManager.setKnown(gActor, id))

#define gHasSeen(id) (memoryEngineManager.getSeen(gActor, id))
#define gSee(id) (memoryEngineManager.setSeen(gActor, id))

#define gHasHeard(id) (memoryEngineManager.getHeard(gActor, id))
#define gHear(id) (memoryEngineManager.setHeard(gActor, id))

#define gHasSmelled(id) (memoryEngineManager.getSmelled(gActor, id))
#define gSmell(id) (memoryEngineManager.setSmelled(gActor, id))

#define gHasTasted(id) (memoryEngineManager.getTasted(gActor, id))
#define gTaste(id) (memoryEngineManager.setTasted(gActor, id))

#define gHasTouched(id) (memoryEngineManager.getTouched(gActor, id))
#define gTouch(id) (memoryEngineManager.setTouched(gActor, id))

Memory template ->_obj;

#define MEMORY_ENGINE_H
