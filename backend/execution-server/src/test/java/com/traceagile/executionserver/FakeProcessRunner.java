package com.traceagile.executionserver;

import com.traceagile.executionserver.process.Cancellation;
import com.traceagile.executionserver.process.ProcessRunner;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.function.Consumer;
import java.util.function.Predicate;

/**
 * Processus scriptés pour les tests : chaque règle reconnaît une ligne de commande et simule le
 * programme (fichiers produits, sortie, code de retour). Sans règle : code 0, aucune sortie.
 */
public class FakeProcessRunner implements ProcessRunner {

    /** Comportement simulé d'un programme. */
    public interface Behaviour {
        Result run(Command command, String commandLine, Consumer<String> output, Cancellation cancellation) throws Exception;
    }

    private record Rule(Predicate<String> matches, Behaviour behaviour) {
    }

    private final List<Rule> rules = new CopyOnWriteArrayList<>();
    private final List<String> executed = new CopyOnWriteArrayList<>();
    private final List<Command> commands = new CopyOnWriteArrayList<>();

    public FakeProcessRunner when(Predicate<String> matches, Behaviour behaviour) {
        rules.addFirst(new Rule(matches, behaviour));
        return this;
    }

    public FakeProcessRunner when(String contains, Behaviour behaviour) {
        return when(line -> line.contains(contains), behaviour);
    }

    public void reset() {
        rules.clear();
        executed.clear();
        commands.clear();
    }

    public List<String> executed() {
        return new ArrayList<>(executed);
    }

    public List<Command> commands() {
        return new ArrayList<>(commands);
    }

    @Override
    public Result run(Command command, Consumer<String> output, Cancellation cancellation) {
        String line = command.arguments().getLast();
        executed.add(line);
        commands.add(command);
        for (Rule rule : rules) {
            if (rule.matches().test(line)) {
                try {
                    return rule.behaviour().run(command, line, output, cancellation);
                } catch (Exception e) {
                    output.accept(e.toString());
                    return new Result(1, false, false, e.toString());
                }
            }
        }
        return new Result(0, false, false, "");
    }

    public static Result ok(String output) {
        return new Result(0, false, false, output);
    }
}
