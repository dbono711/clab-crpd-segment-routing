CLAB = clab-crpd-segment-routing
LOG_FILE = setup.log
VENV_DIR = .venv
REQ_FILE = requirements.txt
ANSIBLE_HOSTS = ansible/hosts
ANSIBLE_PLAYBOOK = ansible/config.yaml
CLIENTS = ce1 ce2 ce3

define log
    echo "[$(shell date '+%Y-%m-%d %H:%M:%S')] $1" >> $(LOG_FILE)
endef

define client_setup
	for CLIENT in $(CLIENTS); do \
		docker cp clients/$$CLIENT.sh $(CLAB)-$$CLIENT:/tmp/; \
		docker exec $(CLAB)-$$CLIENT bash /tmp/$$CLIENT.sh 2>/dev/null; \
	done
endef

.PHONY: initialize_log
initialize_log:
	@echo -n "" > $(LOG_FILE)

.PHONY: initialize-virtual-environment
initialize-virtual-environment: initialize_log
	@if [ ! -f junos.lic ]; then \
		$(call log,A Juniper cRPD license file ('junos.lic') was not found...please download your free eval license key from https://www.juniper.net/us/en/dm/crpd-free-trial.html and rename it to 'junos.lic'); \
		echo "FAILED. Check 'setup.log' for detailed output."; \
		exit 1; \
	fi
	@if [ ! -d $(VENV_DIR) ]; then \
		$(call log,Creating virtual environment...); \
		python3 -m venv $(VENV_DIR) >> $(LOG_FILE) 2>&1; \
		$(call log,Installing requirements in virtual environment...); \
		$(VENV_DIR)/bin/pip install -r $(REQ_FILE) >> $(LOG_FILE) 2>&1; \
	else \
		$(call log,Virtual environment already exists.); \
	fi

.PHONY: lab
lab: initialize-virtual-environment
	@$(call log,Deploying ContainerLAB topology...)
	@sudo clab deploy --topo setup.yml >> $(LOG_FILE) 2>&1
	@sleep 5
	@bash add-license-keys.sh >> $(LOG_FILE) 2>&1
	@$(call log,ContainerLAB topology successfully deployed.)

.PHONY: configure
configure: lab
	@$(call log,Starting configuration...)
	@$(call log,Running ansible playbook for cRPD configuration...)
	@$(VENV_DIR)/bin/ansible-playbook -i $(ANSIBLE_HOSTS) -l network $(ANSIBLE_PLAYBOOK) >> $(LOG_FILE) 2>&1
	@$(call log,Running shell scripts for client configuration...)
	@$(call client_setup) >> $(LOG_FILE) 2>&1
	@echo "Configuration complete. Check 'setup.log' for detailed output."

all: configure

.PHONY: configure-only
configure-only: initialize_log
	@$(call log,Starting configuration...)
	@$(call log,Running ansible playbook for cRPD configuration...)
	@$(VENV_DIR)/bin/ansible-playbook -i $(ANSIBLE_HOSTS) -l network $(ANSIBLE_PLAYBOOK) >> $(LOG_FILE) 2>&1

.PHONY: clean
clean: initialize_log
	@$(call log,Cleaning up...)
	@sudo clab destroy --cleanup --topo setup.yml >> $(LOG_FILE) 2>&1
	@rm -rf $(VENV_DIR) >> $(LOG_FILE) 2>&1
	@$(call log,Cleaning complete.)
	@echo "Cleaning complete. Check 'setup.log' for detailed output."
