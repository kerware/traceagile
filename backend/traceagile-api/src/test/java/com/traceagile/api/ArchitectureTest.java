package com.traceagile.api;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

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
}
