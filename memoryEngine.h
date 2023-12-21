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

Memory template ->obj ->known? ->revealed? ->seen?;

#define MEMORY_ENGINE_H
