//
// memoryEngine.h
//

// Uncomment to enable debugging options.
//#define __DEBUG_MEMORY_ENGINE

// Compile-time flag that disables most of the "advanced" memory
// features.  With this, the module just replicates the stock adv3
// known/revealed/seen behavior.
//#define MEMORY_ENGINE_SIMPLE

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

Memory template ->obj ->known? ->revealed? ->seen?;
Knowledge template ->obj ->known? ->revealed? ->seen?;

#define MEMORY_ENGINE_H
