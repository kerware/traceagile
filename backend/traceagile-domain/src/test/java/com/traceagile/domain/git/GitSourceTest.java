package com.traceagile.domain.git;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

class GitSourceTest {

    @Test
    @DisplayName("ADR-0030 adresse de clonage d'un projet : https, SSH déduit, file:// et forme git@hôte:compte")
    void cloneUrls() {
        GitSource kerware = new GitSource("kerware", "https://github.com/kerware/", null);
        GitProject e2e = new GitProject(kerware, "saucedemo-e2e.git", "master", null);
        assertThat(e2e.getName()).isEqualTo("saucedemo-e2e");
        assertThat(e2e.cloneUrl()).isEqualTo("https://github.com/kerware/saucedemo-e2e");
        assertThat(e2e.webUrl()).isEqualTo("https://github.com/kerware/saucedemo-e2e");
        assertThat(e2e.label()).isEqualTo("kerware / saucedemo-e2e");

        kerware.authenticate(GitAuthType.SSH_KEY, null, "clé-chiffrée");
        assertThat(e2e.cloneUrl()).isEqualTo("git@github.com:kerware/saucedemo-e2e.git");

        GitSource local = new GitSource("Local", "file:///depots", null);
        assertThat(new GitProject(local, "traceagile", null, null).cloneUrl()).isEqualTo("file:///depots/traceagile");
        GitSource gitlab = new GitSource("GitLab", "git@gitlab.example.org:qa", null);
        gitlab.authenticate(GitAuthType.SSH_KEY, null, "clé");
        assertThat(new GitProject(gitlab, "api-tests", null, null).cloneUrl()).isEqualTo("git@gitlab.example.org:qa/api-tests.git");
    }

    @Test
    @DisplayName("ADR-0030 authentification : jeton en https seulement, secret obligatoire, conservé s'il n'est pas ressaisi")
    void authentication() {
        GitSource source = new GitSource("kerware", "https://github.com/kerware", null);
        assertThatThrownBy(() -> source.authenticate(GitAuthType.TOKEN, "bot", null)).extracting("code").isEqualTo("GIT_SOURCE_SECRET_REQUIRED");
        source.authenticate(GitAuthType.TOKEN, "", "jeton-chiffré");
        assertThat(source.getUsername()).isEqualTo("x-access-token");
        source.authenticate(GitAuthType.TOKEN, "bot", null);
        assertThat(source.getUsername()).isEqualTo("bot");
        assertThat(source.getSecretCipher()).isEqualTo("jeton-chiffré");
        // changer de type exige le nouveau secret
        assertThatThrownBy(() -> source.authenticate(GitAuthType.SSH_KEY, null, null)).extracting("code").isEqualTo("GIT_SOURCE_SECRET_REQUIRED");
        source.makePublic();
        assertThat(source.hasSecret()).isFalse();

        GitSource local = new GitSource("Local", "file:///depots", null);
        assertThatThrownBy(() -> local.authenticate(GitAuthType.TOKEN, "u", "s")).extracting("code").isEqualTo("GIT_SOURCE_AUTH_INVALID");
        assertThatThrownBy(() -> new GitSource("x", "ftp://exemple", null)).extracting("code").isEqualTo("GIT_SOURCE_URL_INVALID");
        assertThatThrownBy(() -> new GitProject(source, "mauvais nom", null, null)).extracting("code").isEqualTo("GIT_PROJECT_NAME_INVALID");
    }
}
