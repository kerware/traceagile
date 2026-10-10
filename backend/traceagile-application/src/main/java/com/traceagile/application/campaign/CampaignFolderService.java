package com.traceagile.application.campaign;

import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.application.common.ConflictException;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.campaign.CampaignFolder;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.testcase.TestFolder;
import java.util.List;
import java.util.TreeSet;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * ADR-0018 dossiers de campagnes : dossiers explicites (vides possibles) et dossiers portés par les
 * campagnes. Renommer ou déplacer un dossier reclasse ses campagnes et sous-dossiers.
 */
@Service
@Transactional
public class CampaignFolderService {

    private final CampaignFolderRepository folders;
    private final CampaignRepository campaigns;
    private final ProjectRepository projects;
    private final CampaignService campaignService;

    public CampaignFolderService(CampaignFolderRepository folders, CampaignRepository campaigns, ProjectRepository projects,
                                 CampaignService campaignService) {
        this.folders = folders;
        this.campaigns = campaigns;
        this.projects = projects;
        this.campaignService = campaignService;
    }

    /** Tous les dossiers connus, explicites ou portés par une campagne, avec leurs ancêtres. */
    @Transactional(readOnly = true)
    public List<String> all(String projectKey) {
        TreeSet<String> paths = new TreeSet<>(String.CASE_INSENSITIVE_ORDER);
        folders.findByProject_KeyOrderByPathAsc(projectKey).forEach(f -> addWithAncestors(paths, f.getPath()));
        campaigns.findByProject_KeyOrderByKeyNumberDesc(projectKey).forEach(c -> addWithAncestors(paths, c.getFolder()));
        return List.copyOf(paths);
    }

    public String create(String projectKey, String path) {
        Project project = projects.findByKey(projectKey)
                .orElseThrow(() -> new NotFoundException("PROJECT_NOT_FOUND", "Projet « " + projectKey + " » introuvable."));
        String normalized = CampaignFolder.require(path);
        if (all(projectKey).stream().anyMatch(normalized::equalsIgnoreCase)) {
            throw new ConflictException("CAMPAIGN_FOLDER_EXISTS", "Le dossier « " + normalized + " » existe déjà.");
        }
        return folders.save(new CampaignFolder(project, normalized)).getPath();
    }

    /** Renomme ou déplace une branche ; renvoie le nombre de campagnes reclassées. */
    public int move(String projectKey, String from, String to) {
        String source = CampaignFolder.require(from);
        String target = CampaignFolder.require(to);
        if (!all(projectKey).contains(source)) {
            throw new NotFoundException("CAMPAIGN_FOLDER_NOT_FOUND", "Dossier « " + source + " » introuvable.");
        }
        if (TestFolder.isWithin(target, source) && !target.equals(source)) {
            throw new BusinessRuleException("CAMPAIGN_FOLDER_MOVE_INTO_ITSELF", "Un dossier ne peut pas être déplacé dans l'un de ses sous-dossiers.");
        }
        if (target.equals(source)) {
            return 0;
        }
        List<String> existing = folders.findByProject_KeyOrderByPathAsc(projectKey).stream().map(CampaignFolder::getPath).toList();
        for (CampaignFolder folder : folders.findByProject_KeyOrderByPathAsc(projectKey)) {
            if (TestFolder.isWithin(folder.getPath(), source)) {
                String rebased = TestFolder.rebase(folder.getPath(), source, target);
                if (existing.contains(rebased)) {
                    folders.delete(folder);
                } else {
                    folder.moveTo(rebased);
                }
            }
        }
        List<Campaign> moved = within(projectKey, source);
        moved.forEach(c -> campaignService.relocate(c, TestFolder.rebase(c.getFolder(), source, target)));
        return moved.size();
    }

    /** Supprime un dossier sans campagne (et ses sous-dossiers explicites). */
    public void delete(String projectKey, String path) {
        String root = CampaignFolder.require(path);
        if (!within(projectKey, root).isEmpty()) {
            throw new BusinessRuleException("CAMPAIGN_FOLDER_NOT_EMPTY", "Le dossier « " + root + " » contient des campagnes : déplacez-les d'abord.");
        }
        List<CampaignFolder> branch = folders.findByProject_KeyOrderByPathAsc(projectKey).stream()
                .filter(f -> TestFolder.isWithin(f.getPath(), root)).toList();
        if (branch.isEmpty()) {
            throw new NotFoundException("CAMPAIGN_FOLDER_NOT_FOUND", "Dossier « " + root + " » introuvable.");
        }
        branch.forEach(folders::delete);
    }

    private List<Campaign> within(String projectKey, String root) {
        return campaigns.findByProject_KeyOrderByKeyNumberDesc(projectKey).stream().filter(c -> TestFolder.isWithin(c.getFolder(), root)).toList();
    }

    private static void addWithAncestors(TreeSet<String> paths, String path) {
        if (path == null) {
            return;
        }
        int slash = -1;
        while ((slash = path.indexOf('/', slash + 1)) > 0) {
            paths.add(path.substring(0, slash));
        }
        paths.add(path);
    }
}
