package com.traceagile.executionserver.process;

import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/** Annulation d'un job ou d'une installation : arrête les processus en cours et ceux à venir. */
public final class Cancellation {

    private final Set<Process> running = ConcurrentHashMap.newKeySet();
    private volatile boolean cancelled;

    public static Cancellation none() {
        return new Cancellation();
    }

    public boolean cancelled() {
        return cancelled;
    }

    public void cancel() {
        cancelled = true;
        running.forEach(Cancellation::destroyTree);
    }

    /** @return false si l'annulation est déjà demandée (le processus est alors arrêté aussitôt) */
    boolean attach(Process process) {
        running.add(process);
        if (cancelled) {
            destroyTree(process);
            return false;
        }
        return true;
    }

    void detach(Process process) {
        running.remove(process);
    }

    static void destroyTree(Process process) {
        process.descendants().forEach(ProcessHandle::destroyForcibly);
        process.destroyForcibly();
    }
}
