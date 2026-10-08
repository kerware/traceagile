package com.traceagile.application.requirement;

import com.traceagile.domain.requirement.Invest;
import com.traceagile.domain.requirement.NfrCategory;
import com.traceagile.domain.requirement.Planguage;
import com.traceagile.domain.requirement.Priority;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementType;
import com.traceagile.domain.requirement.RiskLevel;
import com.traceagile.domain.requirement.UserStory;
import java.util.List;
import java.util.Optional;
import java.util.function.Consumer;

/**
 * §12 JSON Merge Patch d'une exigence : un champ {@code null} est laissé tel quel, un
 * {@link Optional#empty()} efface la valeur (ADR-0005, complétée par ADR-0009). Sert aussi à la
 * création et à l'import CSV.
 */
public record RequirementPatch(
        Optional<RequirementType> type,
        Optional<String> title,
        Optional<String> description,
        Optional<String> asA,
        Optional<String> iWant,
        Optional<String> soThat,
        Optional<Priority> priority,
        Optional<Integer> businessValue,
        Optional<Integer> storyPoints,
        Optional<RiskLevel> riskLevel,
        Optional<NfrCategory> category,
        Optional<String> scale,
        Optional<String> measurementMethod,
        Optional<String> minimumThreshold,
        Optional<String> target,
        Optional<String> unit,
        Optional<Boolean> transverse,
        Optional<List<String>> tags,
        Optional<String> externalRef,
        Optional<Invest> invest) {

    public static final RequirementPatch EMPTY = builder().build();

    public static Builder builder() {
        return new Builder();
    }

    /** Applique les champs présents ; le type d'abord, car catégorie et Planguage en dépendent. */
    public void applyTo(Requirement requirement) {
        if (type != null) {
            type.ifPresent(requirement::changeType);
        }
        if (title != null) {
            requirement.rename(title.orElse(null));
        }
        apply(description, requirement::describe);
        if (asA != null || iWant != null || soThat != null) {
            UserStory current = requirement.getUserStory();
            requirement.setUserStory(new UserStory(
                    merge(asA, current.asA()), merge(iWant, current.iWant()), merge(soThat, current.soThat())));
        }
        if (priority != null) {
            priority.ifPresent(requirement::setPriority);
        }
        apply(businessValue, requirement::setBusinessValue);
        apply(storyPoints, requirement::estimate);
        if (riskLevel != null) {
            riskLevel.ifPresent(requirement::setRiskLevel);
        }
        apply(category, requirement::setCategory);
        if (scale != null || measurementMethod != null || minimumThreshold != null || target != null || unit != null) {
            Planguage current = requirement.getPlanguage();
            requirement.setPlanguage(new Planguage(
                    merge(scale, current.scale()), merge(measurementMethod, current.measurementMethod()),
                    merge(minimumThreshold, current.minimumThreshold()), merge(target, current.target()),
                    merge(unit, current.unit())));
        }
        if (transverse != null) {
            requirement.setTransverse(transverse.orElse(false));
        }
        apply(tags, requirement::setTags);
        apply(externalRef, requirement::setExternalRef);
        apply(invest, requirement::setInvest);
    }

    private static <T> void apply(Optional<T> field, Consumer<T> setter) {
        if (field != null) {
            setter.accept(field.orElse(null));
        }
    }

    private static <T> T merge(Optional<T> field, T current) {
        return field == null ? current : field.orElse(null);
    }

    /** Construction fluide ; seuls les champs fixés font partie du patch. */
    public static final class Builder {
        private Optional<RequirementType> type;
        private Optional<String> title;
        private Optional<String> description;
        private Optional<String> asA;
        private Optional<String> iWant;
        private Optional<String> soThat;
        private Optional<Priority> priority;
        private Optional<Integer> businessValue;
        private Optional<Integer> storyPoints;
        private Optional<RiskLevel> riskLevel;
        private Optional<NfrCategory> category;
        private Optional<String> scale;
        private Optional<String> measurementMethod;
        private Optional<String> minimumThreshold;
        private Optional<String> target;
        private Optional<String> unit;
        private Optional<Boolean> transverse;
        private Optional<List<String>> tags;
        private Optional<String> externalRef;
        private Optional<Invest> invest;

        public Builder type(RequirementType v) { type = Optional.ofNullable(v); return this; }
        public Builder title(String v) { title = Optional.ofNullable(v); return this; }
        public Builder description(String v) { description = Optional.ofNullable(v); return this; }
        public Builder userStory(String as, String want, String so) {
            asA = Optional.ofNullable(as);
            iWant = Optional.ofNullable(want);
            soThat = Optional.ofNullable(so);
            return this;
        }
        public Builder priority(Priority v) { priority = Optional.ofNullable(v); return this; }
        public Builder businessValue(Integer v) { businessValue = Optional.ofNullable(v); return this; }
        public Builder storyPoints(Integer v) { storyPoints = Optional.ofNullable(v); return this; }
        public Builder riskLevel(RiskLevel v) { riskLevel = Optional.ofNullable(v); return this; }
        public Builder category(NfrCategory v) { category = Optional.ofNullable(v); return this; }
        public Builder planguage(Planguage v) {
            scale = Optional.ofNullable(v.scale());
            measurementMethod = Optional.ofNullable(v.measurementMethod());
            minimumThreshold = Optional.ofNullable(v.minimumThreshold());
            target = Optional.ofNullable(v.target());
            unit = Optional.ofNullable(v.unit());
            return this;
        }
        public Builder transverse(boolean v) { transverse = Optional.of(v); return this; }
        public Builder tags(List<String> v) { tags = Optional.ofNullable(v); return this; }
        public Builder externalRef(String v) { externalRef = Optional.ofNullable(v); return this; }
        public Builder invest(Invest v) { invest = Optional.ofNullable(v); return this; }

        public RequirementPatch build() {
            return new RequirementPatch(type, title, description, asA, iWant, soThat, priority, businessValue,
                    storyPoints, riskLevel, category, scale, measurementMethod, minimumThreshold, target, unit,
                    transverse, tags, externalRef, invest);
        }
    }
}
