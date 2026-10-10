package com.traceagile.mockserver;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping;
import org.yaml.snakeyaml.Yaml;

/** §15.2 le simulateur expose chaque opération du contrat docs/execution-server-api.yaml. */
@SpringBootTest
class ContractTest {

    static final Path CONTRACT = Path.of("..", "..", "docs", "execution-server-api.yaml");

    @Autowired
    @Qualifier("requestMappingHandlerMapping")
    RequestMappingHandlerMapping mappings;

    @Test
    @DisplayName("§10.2 toutes les opérations du contrat OpenAPI sont implémentées par le simulateur")
    @SuppressWarnings("unchecked")
    void everyOperationIsImplemented() throws Exception {
        Map<String, Object> contract;
        try (InputStream in = Files.newInputStream(CONTRACT)) {
            contract = new Yaml().load(in);
        }
        Map<String, Map<String, Object>> paths = (Map<String, Map<String, Object>>) contract.get("paths");
        List<String> expected = new ArrayList<>();
        paths.forEach((path, operations) -> operations.keySet().forEach(method -> expected.add(method.toUpperCase() + " " + path)));

        List<String> implemented = new ArrayList<>();
        mappings.getHandlerMethods().keySet().forEach(info -> {
            Set<String> patterns = info.getPatternValues();
            info.getMethodsCondition().getMethods().forEach(m -> patterns.forEach(p -> implemented.add(m.name() + " " + p)));
        });
        assertThat(expected).hasSizeGreaterThanOrEqualTo(10);
        assertThat(implemented).containsAll(expected);
    }
}
