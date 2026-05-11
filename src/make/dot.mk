DOT_SOURCES = $(wildcard $(MODULE_DIR)/*/dot.*)

DOT_TARGETS += dot-install
DOT_CLEAN_TARGETS += dot-clean

define dot-rule
DOT_TARGETS += $1
$1: $2
	ln -sf $$< $$@
endef

$(foreach source, $(DOT_SOURCES), \
	$(eval \
		$(call \
			dot-rule, \
			$(patsubst dot.%, ~/.%, $(notdir $(source))), \
			$(source) \
		) \
	) \
)

.PHONY: dot-clean
dot-clean:
	rm -f $(filter-out dot-install,$(DOT_TARGETS))

.PHONY: dot-install
dot-install: $(filter-out dot-install,$(DOT_TARGETS))
