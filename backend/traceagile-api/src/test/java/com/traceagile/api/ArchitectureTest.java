package com.traceagile.api;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;

import com.tngtech.archunit.core.domain.JavaClass;
import com.tngtech.archunit.core.domain.JavaClasses;
import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;
import java.util.HashMap;
import java.util.Map;

/** §15.2 Architecture (ArchUnit) : le domaine ne dépend ni de Spring Web ni de l'infrastructure (§11.3). */
@AnalyzeClasses(packages = "com.traceagile", importOptions = ImportOption.DoNotIncludeTests.class)
class ArchitectureTest {

    @ArchTest
    static final ArchRule domainIsIndependent = noClasses().that().resideInAPackage("com.traceagile.domain..")
            .should().dependOnClassesThat().resideInAnyPackage(
                    "org.springframework.web..", "org.springframework.http..", "jakarta.servlet..",
                    "com.traceagile.application..", "com.traceagile.infrastructure..", "com.traceagile.api..");

    @ArchTest
    static final ArchRule applicationDoesNotDependOnAdapters = noClasses().that().resideInAPackage("com.traceagile.application..")
            .should().dependOnClassesThat().resideInAnyPackage(
                    "org.springframework.web..", "jakarta.servlet..",
                    "com.traceagile.infrastructure..", "com.traceagile.api..");

    @ArchTest
    static final ArchRule infrastructureDoesNotDependOnApi = noClasses().that().resideInAPackage("com.traceagile.infrastructure..")
            .should().dependOnClassesThat().resideInAPackage("com.traceagile.api..");

    /**
     * NF-08 / §12 springdoc nomme les schémas OpenAPI d'après le nom simple de la classe : deux DTO
     * homonymes s'écraseraient dans le contrat (et dans le client généré).
     */
    @ArchTest
    static void dtoNamesAreUnique(JavaClasses all) {
        Map<String, String> seen = new HashMap<>();
        for (JavaClass type : all) {
            if (!type.getPackageName().startsWith("com.traceagile.api") || !type.isRecord()) {
                continue;
            }
            String previous = seen.put(type.getSimpleName(), type.getName());
            if (previous != null) {
                throw new AssertionError("DTO homonymes dans le contrat OpenAPI : " + previous + " et " + type.getName());
            }
        }
    }
}
