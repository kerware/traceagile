package com.traceagile.api.automation;

import com.traceagile.application.automation.AutomatedRunService.RunChanged;
import java.io.IOException;
import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionalEventListener;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

/**
 * F-EXE-07 temps réel : flux Server-Sent Events par run et par campagne. Chaque changement validé
 * (après commit) envoie un événement « run » {runKey, campaignKey} ; le navigateur relit alors le run.
 */
@Component
public class RunEventStreams {

    private static final long TIMEOUT_MS = Duration.ofMinutes(30).toMillis();

    private final Map<String, List<SseEmitter>> streams = new ConcurrentHashMap<>();

    public SseEmitter forRun(String projectKey, String runKey) {
        return open("run:" + projectKey + "/" + runKey);
    }

    public SseEmitter forCampaign(String projectKey, String campaignKey) {
        return open("campaign:" + projectKey + "/" + campaignKey);
    }

    @TransactionalEventListener(fallbackExecution = true)
    public void onRunChanged(RunChanged change) {
        Map<String, String> data = Map.of("runKey", change.runKey(), "campaignKey", change.campaignKey());
        send("run:" + change.projectKey() + "/" + change.runKey(), data);
        send("campaign:" + change.projectKey() + "/" + change.campaignKey(), data);
    }

    private SseEmitter open(String key) {
        SseEmitter emitter = new SseEmitter(TIMEOUT_MS);
        List<SseEmitter> list = streams.computeIfAbsent(key, k -> new CopyOnWriteArrayList<>());
        list.add(emitter);
        Runnable remove = () -> list.remove(emitter);
        emitter.onCompletion(remove);
        emitter.onTimeout(remove);
        emitter.onError(e -> remove.run());
        try {
            emitter.send(SseEmitter.event().name("ready").data(Map.of("stream", key), MediaType.APPLICATION_JSON));
        } catch (IOException e) {
            remove.run();
        }
        return emitter;
    }

    private void send(String key, Map<String, String> data) {
        List<SseEmitter> list = streams.get(key);
        if (list == null) {
            return;
        }
        for (SseEmitter emitter : list) {
            try {
                emitter.send(SseEmitter.event().name("run").data(data, MediaType.APPLICATION_JSON));
            } catch (IOException | IllegalStateException e) {
                list.remove(emitter);
            }
        }
    }
}
