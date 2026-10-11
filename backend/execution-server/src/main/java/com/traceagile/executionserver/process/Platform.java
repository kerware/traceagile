package com.traceagile.executionserver.process;

import java.nio.file.Path;
import java.util.Locale;

/**
 * ADR-0026 le serveur est un jar autonome : il tourne sous Windows, Linux ou macOS. La plateforme
 * choisit l'interpréteur des commandes, les recettes d'installation et la forme des chemins d'outils.
 */
public enum Platform {
    WINDOWS, LINUX, MAC;

    public static Platform current() {
        return of(System.getProperty("os.name"));
    }

    public static Platform of(String osName) {
        String name = osName == null ? "" : osName.toLowerCase(Locale.ROOT);
        if (name.startsWith("windows")) {
            return WINDOWS;
        }
        return name.contains("mac") || name.contains("darwin") ? MAC : LINUX;
    }

    public boolean windows() {
        return this == WINDOWS;
    }

    /** Ligne de commande → arguments du processus (cmd.exe sous Windows, bash ailleurs). */
    public java.util.List<String> shell(String commandLine) {
        return windows() ? java.util.List.of("cmd.exe", "/d", "/s", "/c", commandLine) : java.util.List.of("bash", "-lc", commandLine);
    }

    /** Script d'installation → arguments (PowerShell sous Windows, bash strict ailleurs). */
    public java.util.List<String> script(String script) {
        return windows()
                ? java.util.List.of("powershell.exe", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-Command",
                        "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; "
                                + "function Check { if ($LASTEXITCODE -ne 0) { throw ('Commande en echec, code ' + $LASTEXITCODE) } }; " + script)
                : java.util.List.of("bash", "-c", "set -euo pipefail; " + script);
    }

    /** Dossier des exécutables d'un environnement virtuel Python. */
    public Path venvBin(Path venv) {
        return venv.resolve(windows() ? "Scripts" : "bin");
    }

    /** Dossier des exécutables globaux de npm (préfixe npm). */
    public Path npmBin(Path prefix) {
        return windows() ? prefix : prefix.resolve("bin");
    }

    public String pathSeparator() {
        return windows() ? ";" : ":";
    }

    /** Architecture au sens d'Adoptium (x64, aarch64). */
    public static String arch() {
        String arch = System.getProperty("os.arch", "").toLowerCase(Locale.ROOT);
        return arch.contains("aarch64") || arch.contains("arm64") ? "aarch64" : "x64";
    }

    /** Système au sens d'Adoptium (windows, linux, mac). */
    public String adoptiumOs() {
        return switch (this) {
            case WINDOWS -> "windows";
            case MAC -> "mac";
            case LINUX -> "linux";
        };
    }
}
